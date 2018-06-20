module Ufo
  class Base
    extend Memoist
    include Stack::Helper

    def initialize(service, options)
      @service = switch_current(service)
      @options = options

      @full_service_name = Ufo.full_sevice_name(@service)
      @cluster = @options[:cluster] || default_cluster
      @stack_name = adjust_stack_name(@cluster, @service)
    end

    def switch_current(service)
      Current.service!(service)
    end
  end
end
