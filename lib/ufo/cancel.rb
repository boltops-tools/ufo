module Ufo
  class Cancel < Base
    def run
      stack = find_stack(@stack_name)
      unless stack
        puts "No #{@full_service_name} service to cancel."
        puts "No #{@stack_name} stack to cancel. Exiting"
        exit
      end

      puts "Canceling updates to #{@full_service_name}."
      if stack.stack_status == "CREATE_IN_PROGRESS"
        cloudformation.delete_stack(stack_name: @stack_name)
        puts "Canceling stack creation."
      elsif stack.stack_status =~ /_IN_PROGRESS$/
        cloudformation.cancel_update_stack(stack_name: @stack_name)
        puts "Canceling stack update."
      else
        puts "The stack is not in a state to that is cancelable: #{stack.stack_status}"
      end
    end
  end
end
