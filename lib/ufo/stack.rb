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
    def launch
      stack = find_stack(@stack_name)
      if stack && rollback_complete?(stack)
        puts "Existing stack in ROLLBACK_COMPLETE state. Deleting stack before continuing."
        cloudformation.delete_stack(stack_name: @stack_name)
        status.wait
        status.reset
        stack = nil # at this point stack has been deleted
      end

      @new_stack = true unless stack
      exit_with_message(stack) if stack && !updatable?(stack)

      stack ? perform(:update) : perform(:create)
      status.wait

      if status.rename_rollback_error
        puts status.rename_rollback_error
        puts "A workaround is to run ufo again with STATIC_NAME=0 and to switch to dynamic names for resources. Then run ufo again with STATIC_NAME=1 to get back to statically name resources. Note, please refer to cavaets with the workaround: https://ufoships.com/docs/rename-rollback-error"
      end
    end

    def rollback_complete?(stack)
      stack.stack_status == 'ROLLBACK_COMPLETE'
    end

    def updatable?(stack)
      stack.stack_status =~ /_COMPLETE$/
    end

    def perform(action)
      puts "#{action[0..-2].capitalize}ing stack #{@stack_name.colorize(:green)}..."
      # Example: cloudformation.send("update_stack", stack_options)
      cloudformation.send("#{action}_stack", stack_options)
    rescue Aws::CloudFormation::Errors::ValidationError => e
      handle_stack_error(e)
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

    # if --elb is not set at all, so it's nil. Thhen it defaults to creating the
    # load balancer if the ecs service has a container name "web".
    #
    # --elb '' - wont crete an elb
    # --elb 'auto' - creates an elb
    # --elb arn:... - wont create elb and use the existing target group
    #
    def elb_options
      case @options[:elb]
      when "auto", "true"
        create_elb = "true"
        elb_target_group = ""
      when "", "false", "0"
        create_elb = "false"
        elb_target_group = ""
      when /^arn:aws:elasticloadbalancing.*targetgroup/
        create_elb = "false"
        elb_target_group = @options[:elb]
      when nil
        # default is to create the load balancer is if container name is web
        # and no --elb option is provided
        create_elb = "true" if container_info[:name] == "web"
        elb_target_group = ""
      else
        puts "Invalid --elb option provided: #{@options[:elb].inspect}".colorize(:red)
        puts "Exiting."
        exit 1
      end
      [create_elb, elb_target_group]
    end

    def parameters
      create_elb, elb_target_group = elb_options

      network = Setting::Network.new('default').data
      hash = {
        Subnets: network[:subnets].join(','),
        Vpc: network[:vpc],

        CreateElb: create_elb,
        ElbTargetGroup: elb_target_group,
        EcsDesiredCount: current_desired_count,
        EcsTaskDefinition: task_definition_arn,
        # EcsTaskDefinition: "arn:aws:ecs:us-east-1:160619113767:task-definition/hi-web:191",
      }
      hash[:ElbSecurityGroups] = network[:elb_security_groups].join(',') if network[:elb_security_groups]
      hash[:EcsSecurityGroups] = network[:ecs_security_groups].join(',') if network[:ecs_security_groups]

      hash.map do |k,v|
        { parameter_key: k, parameter_value: v }
      end
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
      path = "/tmp/ufo/stack.yml"
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, template_body)
      puts "Generated template saved at: #{path}"
    end

    # Stack:arn:aws:cloudformation:... is in ROLLBACK_COMPLETE state and can not be updated.
    def handle_stack_error(e)
      case e.message
      when /is in ROLLBACK_COMPLETE state and can not be updated/
        puts "The #{@stack_name} stack is in #{"ROLLBACK_COMPLETE".colorize(:red)} and cannot be updated. Deleted the stack and try again."
        # TODO: fix aws cloudformation console url
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

    def template_scope
      scope = Ufo::TemplateScope.new(Ufo::DSL::Helper.new, nil)
      # Add additional variable to scope for CloudFormation template.
      # Dirties the scope but needed here.
      create_elb, _ = elb_options
      create_elb = create_elb == "true"
      scope.assign_instance_variables(
        options: @options,
        service: @service,
        cluster: @cluster,
        stack_name: @stack_name,
        full_service_name: Ufo.full_sevice_name(@service),
        container_info: container_info,
        dynamic_name: @dynamic_name,
        create_elb: create_elb, # for edge case when ecs service is created before the listener has finished. Sets DependsOn during compile phase.
      )
      scope
    end
    memoize :template_scope

    def exit_with_message(stack)
      region = `aws configure get region`.strip rescue "us-east-1"
      url = "https://console.aws.amazon.com/cloudformation/home?region=#{region}#/stacks"
      puts "The stack is in a state that is not updateable: #{stack.stack_status.colorize(:yellow)}."
      puts "Here's the CloudFormation url to check for more details #{url}"
      exit 1
    end

    # Assume only first container_definition to get the info.
    def container_info
      Ufo.check_task_definition!(@task_definition)
      task_definition_path = ".ufo/output/#{@task_definition}.json"
      task_definition = JSON.load(IO.read(task_definition_path))
      container_def = task_definition["containerDefinitions"].first
      mappings = container_def["portMappings"]
      if mappings
        map = mappings.first
        port = map["containerPort"]
      end
      fargate = task_definition["requiresCompatibilities"] && task_definition["requiresCompatibilities"] == ["FARGATE"]

      {
        name: container_def["name"],
        port: port,
        fargate: fargate,
      }
    end
    memoize :container_info
  end
end
