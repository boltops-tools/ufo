class Ufo::SecurityGroup
  module Helper
    extend Memoist

    def security_group
      Ufo::SecurityGroup.new(@options.merge(service: @service))
    end
    memoize :security_group
  end
end
