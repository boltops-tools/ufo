class Ufo::CLI
  class Destroy < Base
    include Ufo::Hooks::Concern

    def run
      are_you_sure?

      stack = find_stack(@stack_name)
      unless stack
        logger.info "Stack #{@stack_name.color(:green)} does not exist."
        exit 1
      end

      if stack.stack_status =~ /_IN_PROGRESS$/
        logger.info "Cannot destroy service #{@service.color(:green)}"
        logger.info "Cannot delete stack #{@stack_name.color(:green)} in this state: #{stack.stack_status.color(:green)}"
        logger.info "If the stack is taking a long time, you can cancel the current operation with:"
        logger.info "    ufo cancel #{@service}"
        return
      end

      run_hooks(name: "destroy", file: "ufo.rb") do
        cfn.delete_stack(stack_name: @stack_name)
        logger.info "Deleting stack #{@stack_name.color(:green)}"
        return unless @options[:wait]
        status.wait
      end
    end

    def are_you_sure?
      sure?("You are about to destroy the #{@stack_name.color(:green)} stack")
    end
  end
end
