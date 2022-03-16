class Ufo::CLI
  class Destroy < Base
    def run
      are_you_sure?

      stack = find_stack(@stack_name)
      unless stack
        puts "Stack #{@stack_name.color(:green)} does not exist."
        exit 1
      end

      if stack.stack_status =~ /_IN_PROGRESS$/
        puts "Cannot destroy service #{@service.color(:green)}"
        puts "Cannot delete stack #{@stack_name.color(:green)} in this state: #{stack.stack_status.color(:green)}"
        puts "If the stack is taking a long time, you can cancel the current operation with:"
        puts "    ufo cancel #{@service}"
        return
      end

      cfn.delete_stack(stack_name: @stack_name)
      puts "Deleting stack #{@stack_name.color(:green)}"

      return unless @options[:wait]
      status.wait
    end

    def are_you_sure?
      sure?("You are about to destroy the #{@stack_name.color(:green)} stack")
    end
  end
end
