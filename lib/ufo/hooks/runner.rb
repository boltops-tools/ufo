module Ufo::Hooks
  class Runner
    include Ufo::Utils::Logging
    include Ufo::Utils::Execute

    attr_reader :hook
    def initialize(hook)
      @hook = hook
      @execute = @hook["execute"]
    end

    def run
      case @execute
      when String
        execute(@execute, exit_on_fail: @hook["exit_on_fail"])
      when -> (e) { e.respond_to?(:public_instance_methods) && e.public_instance_methods.include?(:call) }
        executor = @execute.new
      when -> (e) { e.respond_to?(:call) }
        executor = @execute
      else
        logger.warn "WARN: execute option not set for hook: #{@hook.inspect}"
      end

      return unless executor

      meth = executor.method(:call)
      case meth.arity
      when 0
        executor.call # backwards compatibility
      when 1
        executor.call(self)
      else
        raise "The #{executor} call method definition has been more than 1 arguments and is not supported"
      end
    end
  end
end
