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

    def initialize(options)
      @options = options
      @task_definition = options[:task_definition]
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

    # do not memoize template_body it can change for a rename retry
    def template_body
      custom_template = "#{Ufo.root}/.ufo/settings/cfn/stack.yml"
      path = if File.exist?(custom_template)
               custom_template
             else
               # built-in default
               File.expand_path("../cfn/stack.yml", File.dirname(__FILE__))
             end
      RenderMePretty.result(path, context: context.scope)
    end

    def stack_options
      save_template
      if ENV['SAVE_TEMPLATE_EXIT']
        puts "Template saved. Exiting."
        exit 1
      end
      {
        parameters: parameters,
        stack_name: @stack_name,
        template_body: template_body,
      }
    end

    def parameters
      create_elb, elb_target_group = context.elb_options

      network = Setting::Profile.new(:network, settings[:network_profile]).data
      # pp network
      elb_subnets = network[:elb_subnets] && !network[:elb_subnets].empty? ?
                    network[:elb_subnets] :
                    network[:ecs_subnets]

      hash = {
        Vpc: network[:vpc],
        ElbSubnets: elb_subnets.join(','),
        EcsSubnets: network[:ecs_subnets].join(','),

        CreateElb: create_elb,
        ElbTargetGroup: elb_target_group,
        ElbEipIds: context.elb_eip_ids,

        EcsDesiredCount: current_desired_count,
        EcsTaskDefinition: task_definition_arn,
        EcsSchedulingStrategy: scheduling_strategy,
      }

      hash[:EcsSecurityGroups] = network[:ecs_security_groups].join(',') if network[:ecs_security_groups]
      hash[:ElbSecurityGroups] = network[:elb_security_groups].join(',') if network[:elb_security_groups]

      hash.map do |k,v|
        if v == :use_previous_value
          { parameter_key: k, use_previous_value: true }
        else
          { parameter_key: k, parameter_value: v }
        end
      end
    end
    memoize :parameters

    def context
      Context.new(@options.merge(
        cluster: @cluster,
        stack_name: @stack_name,
        stack: @stack,
      ))
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
      puts "The stack is not in an updateable state: #{stack.stack_status.color(:yellow)}."
      puts "Here's the CloudFormation url to check for more details #{url}"
      exit 1
    end

    # Assume only first container_definition to get the container info.
    # Stack:arn:aws:cloudformation:... is in ROLLBACK_COMPLETE state and can not be updated.
    def handle_stack_error(e)
      case e.message
      when /state and can not be updated/
        puts "The #{@stack_name} stack is in #{"ROLLBACK_COMPLETE".color(:red)} and cannot be updated. Deleted the stack and try again."
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
      stack.stack_status =~ /_COMPLETE$/
    end
  end
end
