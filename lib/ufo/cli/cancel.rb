class Ufo::CLI
  class Cancel < Base
    def run
      are_you_sure?
      stack = Ufo::Cfn::Stack.new(@options)
      stack.cancel
      stack.status.wait
    end

    def are_you_sure?
      if @options[:yes]
        logger.info "Canceling the #{@stack_name.color(:green)} stack"
      else
        sure?("You are about to cancel the #{@stack_name.color(:green)} stack")
      end
    end
  end
end
