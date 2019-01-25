module Ufo
  class Destroy < Base
    def bye
      unless are_you_sure?
        puts "Phew, that was close"
        return
      end

      stack = find_stack(@stack_name)
      unless stack
        puts "Stack #{@stack_name.color(:green)} does not exist."
        exit
      end

      if stack.stack_status =~ /_IN_PROGRESS$/
        puts "Cannot destroy service #{@pretty_service_name.color(:green)}"
        puts "Cannot delete stack #{@stack_name.color(:green)} in this state: #{stack.stack_status.color(:green)}"
        puts "If the stack is taking a long time, you can cancel the current operation with:"
        puts "  ufo cancel #{@service}"
        return
      end

      cloudformation.delete_stack(stack_name: @stack_name)
      puts "Deleting CloudFormation stack with ECS resources: #{@stack_name}."

      return unless @options[:wait]
      start_time = Time.now
      status.wait
      took = Time.now - start_time
      puts "Time took for deletion: #{status.pretty_time(took).color(:green)}."
    end

    def are_you_sure?
      return true if @options[:sure]
      puts "You are about to destroy #{@pretty_service_name.color(:green)} service on the #{@cluster.color(:green)} cluster."
      print "Are you sure you want to do this? (y/n) "
      answer = $stdin.gets.strip
      answer =~ /^y/
    end
  end
end
