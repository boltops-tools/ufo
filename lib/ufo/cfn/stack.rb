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
module Ufo::Cfn
  class Stack < Base
    extend Memoist

    def deploy
      build
      @stack = find_stack(@stack_name)
      if @stack && rollback_complete?(@stack)
        logger.info "Existing stack in ROLLBACK_COMPLETE state. Deleting stack before continuing."
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

      logger.info status.rollback_error_message if status.update_rollback?

      status.success?
    end

    def perform(action)
      logger.info "#{action[0..-2].capitalize}ing stack #{@stack_name.color(:green)}"
      # Example: cloudformation.send("update_stack", stack_options)

      # o = stack_options.dup
      # o[:template_body] = '...' if o[:template_body]
      # puts "stack_options:"
      # pp o
      # puts "parameters:"
      # pp o[:parameters]

      cloudformation.send("#{action}_stack", stack_options)
    rescue Aws::CloudFormation::Errors::ValidationError => e
      handle_stack_error(e)
    end

    def stack_options
      options = {
        capabilities: ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"],
        parameters: @parameters,
        stack_name: @stack_name,
        template_body: @template_body,
      }
      cfn = Ufo.config.cfn
      options[:notification_arns] = cfn.notification_arns if cfn.notification_arns
      options[:disable_rollback] = cfn.disable_rollback unless cfn.disable_rollback.nil?
      options[:tags] = tags(cfn.tags) if cfn.tags
      options
    end

    def tags(hash)
      hash.map do |k,v|
        { key: v, value: v }
      end
    end

    def build
      options_with_vars = @options.dup.merge(vars: vars.values)
      params = Params.new(options_with_vars)
      @parameters = params.build
      template = Template.new(options_with_vars)
      @template_body = template.body
    end

    def vars
      o = @options.merge(
        cluster: @cluster,
        stack_name: @stack_name,
        stack: @stack,
      )
      o[:rollback_task_definition] = rollback_task_definition if rollback_task_definition
      Vars.new(o)
    end
    memoize :vars

    def scheduling_strategy
      scheduling_strategy = Ufo.config.ecs.scheduling_strategy
      scheduling_strategy.upcase if scheduling_strategy
    end

    def rollback_task_definition
      return unless @options[:rollback]
      @options[:rollback_task_definition]
    end
    memoize :rollback_task_definition

    def exit_with_message(stack)
      region = `aws configure get region`.strip rescue "us-east-1"
      url = "https://console.aws.amazon.com/cloudformation/home?region=#{region}#/stacks"
      logger.info "The stack is not in an updateable state: #{stack.stack_status.color(:yellow)}."
      logger.info "Here's the CloudFormation url to check for more details #{url}"
      exit 1
    end

    # Assume only first container_definition to get the container info.
    # Stack:arn:aws:cloudformation:... is in ROLLBACK_COMPLETE state and can not be updated.
    def handle_stack_error(e)
      case e.message
      when /state and can not be updated/
        logger.info "The #{@stack_name} stack is in a state that cannot be updated. Deleted the stack and try again."
        logger.info "ERROR: #{e.message}"
        if message.include?('UPDATE_ROLLBACK_FAILED')
          logger.info "You might be able to do a 'Continue Update Rollback' and skip some resources to get the stack back into a good state."
        end
        region = `aws configure get region`.strip rescue 'us-east-1'
        url = "https://console.aws.amazon.com/cloudformation/home?region=#{region}"
        logger.info "Here's the CloudFormation console url: #{url}"
        exit 1
      when /No updates are to be performed/
        logger.info "There are no updates to be performed. Exiting.".color(:yellow)
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

    def cancel
      stack = find_stack(@stack_name)
      unless stack
        logger.error "No #{@stack_name} stack to cancel".color(:red)
        exit 1
      end

      if stack.stack_status == "CREATE_IN_PROGRESS"
        cloudformation.delete_stack(stack_name: @stack_name)
        logger.info "Canceling stack creation"
      elsif stack.stack_status == "UPDATE_IN_PROGRESS"
        cloudformation.cancel_update_stack(stack_name: @stack_name)
        logger.info "Canceling stack update"
      else
        logger.info "The stack is not in a state to that is cancelable: #{stack.stack_status}"
      end
    end
  end
end
