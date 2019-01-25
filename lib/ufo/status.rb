module Ufo
  class Status < Base
    # used for the ufo status command
    def run
      unless stack_exists?(@stack_name)
        puts "The stack #{@stack_name.color(:green)} does not exist."
        return
      end

      resp = cloudformation.describe_stacks(stack_name: @stack_name)
      stack = resp.stacks.first

      puts "The current status for the stack #{@stack_name.color(:green)} is #{stack.stack_status.color(:green)}"

      status_poller = Stack::Status.new(@stack_name)

      if stack.stack_status =~ /_IN_PROGRESS$/
        puts "Stack events (tailing):"
        # tail all events until done
        status_poller.hide_time_took = true
        status_poller.wait
      else
        puts "Stack events:"
        # show the last events that was user initiated
        status_poller.refresh_events
        status_poller.show_events(true)
      end
    end

    def stack_exists?(stack_name)
      return true if ENV['TEST']
      return false if @options[:noop]

      exist = nil
      begin
        # When the stack does not exist an exception is raised. Example:
        # Aws::CloudFormation::Errors::ValidationError: Stack with id blah does not exist
        resp = cloudformation.describe_stacks(stack_name: stack_name)
        exist = true
      rescue Aws::CloudFormation::Errors::ValidationError => e
        if e.message =~ /does not exist/
          exist = false
        elsif e.message.include?("'stackName' failed to satisfy constraint")
          # Example of e.message when describe_stack with invalid stack name
          # "1 validation error detected: Value 'instance_and_route53' at 'stackName' failed to satisfy constraint: Member must satisfy regular expression pattern: [a-zA-Z][-a-zA-Z0-9]*|arn:[-a-zA-Z0-9:/._+]*"
          puts "Invalid stack name: #{stack_name}"
          puts "Full error message: #{e.message}"
          exit 1
        else
          raise # re-raise exception  because unsure what other errors can happen
        end
      end
      exist
    end
  end
end
