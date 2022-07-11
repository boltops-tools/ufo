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
    include Ufo::TaskDefinition::Helpers::AwsHelper
    include Ufo::Hooks::Concern

    def deploy
      build
      @stack = find_stack(@stack_name)
      if @stack && rollback_complete?(@stack)
        logger.info "Existing stack in ROLLBACK_COMPLETE state. Deleting stack before continuing."
        cfn.delete_stack(stack_name: @stack_name)
        status.wait
        status.reset
        @stack = nil # at this point stack has been deleted
      end

      exit_with_message(@stack) if @stack && !updatable?(@stack)

      run_hooks(name: "ship", file: "ufo.rb") do
        @stack ? perform(:update) : perform(:create)
        stop_old_tasks if @options[:stop_old_task]
        return unless @options[:wait]
        status.wait
      end

      logger.info status.rollback_error_message if status.update_rollback?
      status.success?
    end

    def perform(action)
      logger.info "#{action[0..-2].capitalize}ing stack #{@stack_name.color(:green)}"
      cfn.send("#{action}_stack", stack_options) # Example: cfn.send("update_stack", stack_options)
    rescue Aws::CloudFormation::Errors::ValidationError => e
      try_continue_update_rollback = continue_update_rollback(e)
      try_continue_update_rollback && retry
      handle_stack_error(e)
    end

    # Super edge case where stack is in UPDATE_ROLLBACK_FAILED. Can reproduce by:
    #
    #   1. spinning ECS cluster down to 0 and deploying with ufo ship
    #   2. after 3h will timeout and fail and goes into UPDATE_ROLLBACK_FAILED
    #
    # Screenshot: https://capture.dropbox.com/Pdr8gijnaQvoMp2y
    #
    # Will auto-retry once
    #
    def continue_update_rollback(e)
      if e.message.include?('UPDATE_ROLLBACK_FAILED') && !@continue_update_rollback_tried
        logger.info "Stack in UPDATE_ROLLBACK_FAILED"
        logger.info "Trying a continue_update_rollback and will retry again once"
        cfn.continue_update_rollback(stack_name: @stack_name)
        status.wait
        @continue_update_rollback_tried ||= true
      else
        false
      end
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

    # Run hooks here so both ufo docker and ufo ship runs it
    #     ufo docker => CLI::Build#build => Cfn::Stack#build
    def build
      run_hooks(name: "build", file: "ufo.rb") do
        vars = Vars.new(@options).values
        options_with_vars = @options.dup.merge(vars: vars)
        params = Params.new(options_with_vars)
        @parameters = params.build
        template = Template.new(options_with_vars)
        @template_body = template.body
      end
    end

    def scheduling_strategy
      scheduling_strategy = Ufo.config.ecs.scheduling_strategy
      scheduling_strategy.upcase if scheduling_strategy
    end

    def exit_with_message(stack)
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
        if e.message.include?('UPDATE_ROLLBACK_FAILED')
          logger.info "You might be able to do a 'Continue Update Rollback' and skip some resources to get the stack back into a good state."
        end
        url = "https://console.aws.amazon.com/cloudformation/home?region=#{region}"
        logger.info "Here's the CloudFormation console url: #{url}"
        exit 1
      when /No updates are to be performed/
        logger.info "There are no updates to be performed. Exiting.".color(:yellow)
        exit 1
      when /YAML not well-formed/ # happens if a value is a serialize Ruby Object. See: https://gist.github.com/tongueroo/737531d0bc8c92d92b5cd00493e15d9e
        # e.message: Template format error: YAML not well-formed. (line 207, column 9)
        print_code(e)
      else
        raise
      end
    end

    def print_code(exception)
      path = ".ufo/output/template.yml"
      md = exception.message.match(/line (\d+),/)
      line_number = md[1]
      logger.error "Template for debugging: #{path}"
      if md
        DslEvaluator.print_code(path, line_number)
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
        cfn.delete_stack(stack_name: @stack_name)
        logger.info "Canceling stack creation"
      elsif stack.stack_status == "UPDATE_IN_PROGRESS"
        cfn.cancel_update_stack(stack_name: @stack_name)
        logger.info "Canceling stack update"
      else
        logger.info "The stack is not in a state to that is cancelable: #{stack.stack_status}"
      end
    end
  end
end
