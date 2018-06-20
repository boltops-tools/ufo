class Ufo::Stack
  module Helper
    extend Memoist

    def adjust_stack_name(stack_name)
      stack_name || raise("stack_name required")
      [stack_name, ENV['UFO_ENV_EXTRA']].compact.join('-')
    end

    def status
      Status.new(@stack_name)
    end
    memoize :status
  end
end
