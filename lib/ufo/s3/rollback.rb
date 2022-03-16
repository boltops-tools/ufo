module Ufo::S3
  class Rollback
    extend Memoist
    include Ufo::AwsServices
    include Ufo::Utils::Logging

    def initialize(stack)
      @stack = stack
    end

    def delete_stack
      return unless complete?
      logger.info "Existing stack in ROLLBACK_COMPLETE state. Deleting stack before continuing."
      cfn.delete_stack(stack_name: @stack)
      status.wait
      status.reset
      true
    end

    def continue_update
      continue_update?
      begin
        cfn.continue_update_rollback(stack_name: @stack)
      rescue Aws::CloudFormation::Errors::ValidationError => e
        logger.info "ERROR: Continue update: #{e.message}".color(:red)
        quit 1
      end
    end

    def continue_update?
      logger.info <<~EOL
        The stack is in the UPDATE_ROLLBACK_FAILED state. More info here: https://amzn.to/2IiEjc5
        Would you like to try to continue the update rollback? (y/N)
      EOL

      yes = @options[:yes] ? "y" : $stdin.gets
      unless yes =~ /^y/
        logger.info "Exiting without continuing the update rollback."
        quit 0
      end
    end

    def complete?
      stack&.stack_status == 'ROLLBACK_COMPLETE'
    end

    def stack
      find_stack(@stack)
    end
    memoize :stack
  end
end
