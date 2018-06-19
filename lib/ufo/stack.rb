module Ufo
  class Stack
    autoload :Status, "ufo/stack/status"

    include AwsService
    extend Memoist

    def initialize(options)
      @options = options
      @stack_name = options[:stack_name] || raise("stack_name required")
      @service = options[:service]
      @task_definition = options[:task_definition]
      @cluster = options[:cluster]
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
      # resp = cloudformation.describe_stack_events(stack_name: @stack_name)
      # IO.write("/tmp/stack-events.json", JSON.pretty_generate(resp.to_h))
      # puts "EXIT EARLY"
      # exit 1

      stack = find_stack(@stack_name)
      exit_with_message(stack) if stack && !updatable?(stack)

      stack ? update_stack : create_stack
      status.wait

      puts "Finished stack."
    end

    def find_stack(stack_name)
      resp = cloudformation.describe_stacks(stack_name: stack_name)
      stack = resp.stacks.first
    rescue Aws::CloudFormation::Errors::ValidationError => e
      # example: Stack with id hi-web does not exist
      if e.message =~ /Stack with/ && e.message =~ /does not exist/
        nil
      else
        raise
      end
    end

    def stack_options
      puts template_body
      # puts "parameters: "
      # pp parameters
      # puts "EXIT EARLY 1"
      # exit 1

      {
        parameters: parameters,
        stack_name: @stack_name,
        template_body: template_body,
      }
    end

    def create_stack
      puts "Creating stack #{@stack_name}..."
      cloudformation.create_stack(stack_options)
    end

    def update_stack
      puts "Updating stack..."
      begin
        cloudformation.update_stack(stack_options)
      rescue Aws::CloudFormation::Errors::ValidationError => e
        handle_update_stack_error(e)
      end
    end

    def parameters
      network = Setting::Network.new('default').data
      ecs_task_definition = 'arn:aws:ecs:us-east-1:160619113767:task-definition/hi-web:191'

      # --elb ''
      # --elb 'auto'
      # --elb arn
      case @options[:elb]
      when "auto"
        create_elb = "true"
        elb_target_group = ""
      when ""
        create_elb = "false"
        elb_target_group = ""
      when /^arn:aws:elasticloadbalancing.*targetgroup/
        create_elb = "false"
        elb_target_group = @options[:elb]
      else
        raise "Invalid elb option provided: #{@options[:elb].inspect}"
      end

      hash = {
        ElbSecurityGroups: network[:elb_security_groups].join(','),
        EcsSecurityGroups: network[:ecs_security_groups].join(','),

        Subnets: network[:subnets].join(','),
        Vpc: network[:vpc],

        CreateElb: create_elb,
        ElbTargetGroup: elb_target_group,
        EcsDesiredCount: "1",
        EcsTaskDefinition: ecs_task_definition,
      }
      hash.map do |k,v|
        { parameter_key: k, parameter_value: v }
      end
    end

    # Stack:arn:aws:cloudformation:... is in ROLLBACK_COMPLETE state and can not be updated.
    def handle_update_stack_error(e)
      case e.message
      when /is in ROLLBACK_COMPLETE state and can not be updated/
        puts "The #{@stack_name} stack is in #{"ROLLBACK_COMPLETE".colorize(:red)} and cannot be updated. Deleted the stack and try again."
        # TODO: fix aws cloudformation console url
        url = "https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/"
        puts "Here's the CloudFormation console url: "
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
      path = File.expand_path("../cfn/stack.yml", File.dirname(__FILE__))
      RenderMePretty.result(path, context: template_scope)
    end

    def template_scope
      scope = Ufo::TemplateScope.new(Ufo::DSL::Helper.new, nil)
      # Add additional variable to scope for CloudFormation template.
      # Dirties the scope but needed here.
      scope.assign_instance_variables(
        options: @options,
        stack_name: @stack_name,
        service: @service,
        container_info: container_info(@task_definition),
        dynamic_name: @dynamic_name,
      )
      scope
    end
    memoize :template_scope

    def exit_with_message(stack)
      region = `aws configure get region`.strip rescue "us-east-1"
      url = "https://console.aws.amazon.com/cloudformation/home?region=#{region}#/stacks"
      puts "The stack state is in: #{stack.stack_status}."
      puts "Here's the CloudFormation url to check for more details #{url}"
      exit 1
    end

    def status
      Status.new(@stack_name)
    end
    memoize :status

    def updatable?(stack)
      stack.stack_status =~ /_COMPLETE$/
    end

    # Assume only first container_definition to get the info.
    def container_info(task_definition)
      Ufo.check_task_definition!(task_definition)
      task_definition_path = ".ufo/output/#{task_definition}.json"
      task_definition = JSON.load(IO.read(task_definition_path))
      container_def = task_definition["containerDefinitions"].first
      mappings = container_def["portMappings"]
      if mappings
        map = mappings.first
        port = map["containerPort"]
      end
      {
        name: container_def["name"],
        port: port
      }
    end
    memoize :container_info
  end
end
