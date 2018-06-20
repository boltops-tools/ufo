module Ufo
  class Cancel
    include Stack::Helper

    def initialize(service, options)
      @service = service
      @options = options
      @cluster = @options[:cluster] || default_cluster
      @stack_name = adjust_stack_name(@cluster, @service)
    end

    def run
      stack = find_stack(@stack_name)
      unless stack
        return "No #{@stack_name} stack to cancel. Exiting"
        exit
      end

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
