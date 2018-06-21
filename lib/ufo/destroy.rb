module Ufo
  class Destroy < Base
    def bye
      unless are_you_sure?
        puts "Phew, that was close"
        return
      end

      stack = find_stack(@stack_name)
      unless stack
        puts "Stack #{@stack_name} does not exit"
        exit
      end

      cloudformation.delete_stack(stack_name: @stack_name)
      puts "Deleting CloudFormation stack with ECS resources: #{@stack_name}."
      status.wait
    end

    def are_you_sure?
      return true if @options[:sure]
      puts "You are about to destroy #{@pretty_service_name.colorize(:green)} service on the #{@cluster.colorize(:green)} cluster."
      print "Are you sure you want to do this? (y/n) "
      answer = $stdin.gets.strip
      answer =~ /^y/
    end
  end
end
