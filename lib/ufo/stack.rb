# CloudFormation status codes, full list:
#   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
#
#   CREATE_COMPLETE
#   ROLLBACK_COMPLETE
#   DELETE_COMPLETE
#   UPDATE_COMPLETE
#   UPDATE_ROLLBACK_COMPLETE
#
#   CREATE_FAILED
#   DELETE_FAILED
#   ROLLBACK_FAILED
#   UPDATE_ROLLBACK_FAILED
#
#   CREATE_IN_PROGRESS
#   DELETE_IN_PROGRESS
#   REVIEW_IN_PROGRESS
#   ROLLBACK_IN_PROGRESS
#   UPDATE_COMPLETE_CLEANUP_IN_PROGRESS
#   UPDATE_IN_PROGRESS
#   UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS
#   UPDATE_ROLLBACK_IN_PROGRESS
#
module Ufo
  class Stack
    autoload :Status, "ufo/stack/status"
    autoload :Helper, "ufo/stack/helper"
    include Helper
    extend Memoist

    def initialize(options)
      @options = options
      @task_definition = options[:task_definition]
      @service = options[:service]
      @cluster = @options[:cluster] || default_cluster
      @stack_name = adjust_stack_name(@cluster, options[:service])
    end

    def launch
      @stack = find_stack(@stack_name)
      if @stack && rollback_complete?(@stack)
        puts "Existing stack in ROLLBACK_COMPLETE state. Deleting stack before continuing."
        cloudformation.delete_stack(stack_name: @stack_name)
        @status.wait
        @status.reset
        @stack = nil # at this point stack has been deleted
      end

      @new_stack = true unless @stack
      exit_with_message(@stack) if @stack && !updatable?(@stack)

      @stack ? perform(:update) : perform(:create)
      status.wait

      if status.rename_rollback_error
        puts status.rename_rollback_error
        puts "A workaround is to run ufo again with STATIC_NAME=0 and to switch to dynamic names for resources. Then run ufo again with STATIC_NAME=1 to get back to statically name resources. Note, please refer to cavaets with the workaround: https://ufoships.com/docs/rename-rollback-error"
      end
    end

    def perform(action)
      puts "#{action[0..-2].capitalize}ing stack #{@stack_name.colorize(:green)}..."
      # Example: cloudformation.send("update_stack", stack_options)
      cloudformation.send("#{action}_stack", stack_options)
    rescue Aws::CloudFormation::Errors::ValidationError => e
      handle_stack_error(e)
    end

    # do not memoize template_body it can change for a rename retry
    def template_body
      custom_template = "#{Ufo.root}/.ufo/settings/cfn/default/stack.yml"
      path = if File.exist?(custom_template)
               custom_template
             else
               # built-in default
               File.expand_path("../cfn/stack.yml", File.dirname(__FILE__))
             end
      RenderMePretty.result(path, context: template_scope)
    end

    def stack_options
      # puts template_body
      # puts "parameters: "
      # pp parameters
      # puts "template_scope: #{template_scope.inspect}"
      # puts "EXIT EARLY 1" ; exit 1

      save_template
      {
        parameters: parameters,
        stack_name: @stack_name,
        template_body: template_body,
      }
    end

    def parameters
      create_elb, elb_target_group = elb_options

      network = Setting::Network.new(settings["network_profile"]).data
      hash = {
        Subnets: network[:subnets].join(','),
        Vpc: network[:vpc],

        CreateElb: create_elb,
        ElbTargetGroup: elb_target_group,
        EcsDesiredCount: current_desired_count,
        EcsTaskDefinition: task_definition_arn,
        # EcsTaskDefinition: "arn:aws:ecs:us-east-1:111111111111:task-definition/hi-web:191",
      }
      hash[:ElbSecurityGroups] = network[:elb_security_groups].join(',') if network[:elb_security_groups]
      hash[:EcsSecurityGroups] = network[:ecs_security_groups].join(',') if network[:ecs_security_groups]

      hash.map do |k,v|
        if v == :use_previous_value
          { parameter_key: k, use_previous_value: true }
        else
          { parameter_key: k, parameter_value: v }
        end
      end
    end

    def template_scope
      scope = Ufo::TemplateScope.new(Ufo::DSL::Helper.new, nil)
      # Add additional variable to scope for CloudFormation template.
      # Dirties the scope but needed.
      scope.assign_instance_variables(
        cluster: @cluster,
        pretty_service_name: Ufo.pretty_service_name(@service),
        container_info: container_info,
        # elb options remember their 'state'
        create_elb: create_elb, # helps set Ecs DependsOn
        elb_type: elb_type,
      )
      scope
    end
    memoize :template_scope

    def elb_type
      # if option explicitly specified then change the elb type
      return @options[:elb_type] if @options[:elb_type]

      # if not explicitly set, then it depends if its a new stack
      return "application" if @new_stack # default for new stack

      # use existing load balancer type
      resp = cloudformation.describe_stack_resources(stack_name: @stack_name)
      resources = resp.stack_resources
      elb_resource = resources.find do |resource|
        resource.logical_resource_id == "Elb"
      end

      # In the case when stack exists and there is no elb resource, the elb type
      # doesnt really matter because the elb wont be created since the CreateElb
      # parameter is set to false. The elb type only needs to be set for the
      # template to validate.
      return "application" unless elb_resource

      resp = elb.describe_load_balancers(load_balancer_arns: [elb_resource.physical_resource_id])
      load_balancer = resp.load_balancers.first
      load_balancer.type
    end
    memoize :elb_type

    def create_elb
      create_elb, _ = elb_options
      create_elb == "true" # convert to boolean
    end

    # if --elb is not set at all, so it's nil. Thhen it defaults to creating the
    # load balancer if the ecs service has a container name "web".
    #
    # --elb '' - wont crete an elb
    # --elb 'auto' - creates an elb
    # --elb arn:... - wont create elb and use the existing target group
    #
    def elb_options
      case @options[:elb]
      when "auto", "true", "yes"
        create_elb = "true"
        elb_target_group = ""
      when "false", "0", "no"
        create_elb = "false"
        elb_target_group = ""
      when /^arn:aws:elasticloadbalancing.*targetgroup/
        create_elb = "false"
        elb_target_group = @options[:elb]
      when "", nil
        create_elb, elb_target_group = default_elb_options
      else
        puts "Invalid --elb option provided: #{@options[:elb].inspect}".colorize(:red)
        puts "Exiting."
        exit 1
      end
      [create_elb, elb_target_group]
    end

    def default_elb_options
      # cannot use :use_previous_value because need to know the create_elb value to
      # compile a template with the right DependsOn for the Ecs service
      unless @new_stack
        create_elb = get_parameter_value(@stack, "CreateElb")
        elb_target_group = get_parameter_value(@stack, "ElbTargetGroup")
        return [create_elb, elb_target_group]
      end

      # default is to create the load balancer is if container name is web
      # and no --elb option is provided
      create_elb = "true" if container_info[:name] == "web"
      elb_target_group = ""
      [create_elb, elb_target_group]
    end

    def get_parameter_value(stack, key)
      param = stack.parameters.find do |p|
        p.parameter_key == key
      end
      param.parameter_value
    end

    def current_desired_count
      info = Info.new(@service, @options)
      service = info.service
      if service
        service.desired_count.to_s
      else
        "1" # new service
      end
    end

    def task_definition_arn
      resp = ecs.describe_task_definition(task_definition: @task_definition)
      resp.task_definition.task_definition_arn
    end
    memoize :task_definition_arn

    # Store template in tmp in case for debugging
    def save_template
      path = "/tmp/ufo/#{@stack_name}/stack.yml"
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, template_body)
      puts "Generated template saved at: #{path}"

      path = "/tmp/ufo/#{@stack_name}/parameters.yml"
      IO.write(path, JSON.pretty_generate(parameters))
      puts "Generated parameters saved at: #{path}"
    end

    def exit_with_message(stack)
      region = `aws configure get region`.strip rescue "us-east-1"
      url = "https://console.aws.amazon.com/cloudformation/home?region=#{region}#/stacks"
      puts "The stack is not in an updateable state: #{stack.stack_status.colorize(:yellow)}."
      puts "Here's the CloudFormation url to check for more details #{url}"
      exit 1
    end

    # Assume only first container_definition to get the info.
    def container_info
      resp = ecs.describe_task_definition(task_definition: @task_definition)
      task_definition = resp.task_definition

      container_def = task_definition["container_definitions"].first
      mappings = container_def["port_mappings"]
      if mappings
        map = mappings.first
        port = map["container_port"]
      end
      requires_compatibilities = task_definition["requires_compatibilities"]
      fargate = requires_compatibilities && requires_compatibilities == ["FARGATE"]
      network_mode = task_definition["network_mode"]

      {
        name: container_def["name"],
        port: port,
        fargate: fargate,
        network_mode: network_mode,
      }
    end
    memoize :container_info

    # Stack:arn:aws:cloudformation:... is in ROLLBACK_COMPLETE state and can not be updated.
    def handle_stack_error(e)
      case e.message
      when /is in ROLLBACK_COMPLETE state and can not be updated/
        puts "The #{@stack_name} stack is in #{"ROLLBACK_COMPLETE".colorize(:red)} and cannot be updated. Deleted the stack and try again."
        region = `aws configure get region`.strip rescue 'us-east-1'
        url = "https://console.aws.amazon.com/cloudformation/home?region=#{region}"
        puts "Here's the CloudFormation console url: #{url}"
        exit 1
      when /No updates are to be performed/
        puts "There are no updates to be performed. Exiting.".colorize(:yellow)
        exit 1
      else
        raise
      end
    end

    def rollback_complete?(stack)
      stack.stack_status == 'ROLLBACK_COMPLETE'
    end

    def updatable?(stack)
      stack.stack_status =~ /_COMPLETE$/
    end
  end
end
