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
    extend Memoist
    include Helper
    include Ufo::Settings

    def initialize(options)
      @options = options
      @task_definition = options[:task_definition]
      @rollback = options[:rollback]
      @service = options[:service]
      @cluster = @options[:cluster] || default_cluster(@service)
      @stack_name = adjust_stack_name(@cluster, options[:service])
    end

    def deploy
      @stack = find_stack(@stack_name)
      if @stack && rollback_complete?(@stack)
        puts "Existing stack in ROLLBACK_COMPLETE state. Deleting stack before continuing."
        cloudformation.delete_stack(stack_name: @stack_name)
        status.wait
        status.reset
        @stack = nil # at this point stack has been deleted
      end

      exit_with_message(@stack) if @stack && !updatable?(@stack)

      @stack ? perform(:update) : perform(:create)

      stop_old_tasks if @options[:stop_old_task]

      return unless @options[:wait]
      status.wait

      puts status.rollback_error_message if status.update_rollback?

      status.success?
    end

    def perform(action)
      puts "#{action[0..-2].capitalize}ing stack #{@stack_name.color(:green)}..."
      # Example: cloudformation.send("update_stack", stack_options)
      cloudformation.send("#{action}_stack", stack_options)
    rescue Aws::CloudFormation::Errors::ValidationError => e
      handle_stack_error(e)
    end

    def stack_options
      save_template
      if ENV['SAVE_TEMPLATE_EXIT']
        puts "Template saved. Exiting."
        exit 1
      end
      {
        capabilities: ["CAPABILITY_IAM"],
        notification_arns: notification_arns,
        parameters: parameters,
        stack_name: @stack_name,
        template_body: template_body,
      }
    end

    def notification_arns
      settings[:notification_arns] || []
    end

    def parameters
      create_elb, elb_target_group = context.elb_options

      elb_subnets = network[:elb_subnets] && !network[:elb_subnets].empty? ?
                    network[:elb_subnets] :
                    network[:ecs_subnets]

      params = {
        Vpc: network[:vpc],
        ElbSubnets: elb_subnets.join(','),
        EcsSubnets: network[:ecs_subnets].join(','),

        CreateElb: create_elb,
        ElbTargetGroup: elb_target_group,
        ElbEipIds: context.elb_eip_ids,

        EcsDesiredCount: current_desired_count,
        EcsSchedulingStrategy: scheduling_strategy,
      }

      params = Ufo::Utils::Squeezer.new(params).squeeze
      params.map do |k,v|
        if v == :use_previous_value
          { parameter_key: k, use_previous_value: true }
        else
          { parameter_key: k, parameter_value: v }
        end
      end
    end
    memoize :parameters

    # do not memoize template_body it can change for a rename retry
    def template_body
      TemplateBody.new(context).build
    end
    memoize :template_body

    def context
      o = @options.merge(
        cluster: @cluster,
        stack_name: @stack_name,
        stack: @stack,
      )
      o[:rollback_definition_arn] = rollback_definition_arn if rollback_definition_arn
      Context.new(o)
    end
    memoize :context

    def scheduling_strategy
      strategy = @options[:scheduling_strategy] || context.scheduling_strategy
      strategy.upcase
    end

    def current_desired_count
      # Cannot set ECS desired count when is scheduling_strategy DAEMON
      return '' if scheduling_strategy == "DAEMON"

      info = Info.new(@service, @options)
      service = info.service
      if service
        service.desired_count.to_s
      else
        "1" # new service default
      end
    end

    def rollback_definition_arn
      return unless @rollback
      resp = ecs.describe_task_definition(task_definition: @task_definition)
      resp.task_definition.task_definition_arn
    end
    memoize :rollback_definition_arn

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
      puts "The stack is not in an updateable state: #{stack.stack_status.color(:yellow)}."
      puts "Here's the CloudFormation url to check for more details #{url}"
      exit 1
    end

    # Assume only first container_definition to get the container info.
    # Stack:arn:aws:cloudformation:... is in ROLLBACK_COMPLETE state and can not be updated.
    def handle_stack_error(e)
      case e.message
      when /state and can not be updated/
        puts "The #{@stack_name} stack is in a state that cannot be updated. Deleted the stack and try again."
        puts "ERROR: #{e.message}"
        if message.include?('UPDATE_ROLLBACK_FAILED')
          puts "You might be able to do a 'Continue Update Rollback' and skip some resources to get the stack back into a good state."
        end
        region = `aws configure get region`.strip rescue 'us-east-1'
        url = "https://console.aws.amazon.com/cloudformation/home?region=#{region}"
        puts "Here's the CloudFormation console url: #{url}"
        exit 1
      when /No updates are to be performed/
        puts "There are no updates to be performed. Exiting.".color(:yellow)
        exit 1
      else
        raise
      end
    end

    def rollback_complete?(stack)
      stack.stack_status == 'ROLLBACK_COMPLETE'
    end

    def updatable?(stack)
      stack.stack_status =~ /_COMPLETE$/ || stack.stack_status == 'UPDATE_ROLLBACK_FAILED'
    end
  end
end
