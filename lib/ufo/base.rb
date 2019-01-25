module Ufo
  class Base
    extend Memoist
    include Stack::Helper

    def initialize(service, options={})
      @service = switch_current(service)
      @options = options

      @pretty_service_name = Ufo.pretty_service_name(@service)
      @cluster = @options[:cluster] || default_cluster
      @stack_name = adjust_stack_name(@cluster, @service)
    end

    def switch_current(service)
      Current.service!(service)
    end

    def info
      Info.new(@service, @options)
    end
    memoize :info

    def no_service_message
      <<-EOL
No #{@pretty_service_name.color(:green)} found.
No CloudFormation stack named #{@stack_name} found.
Are sure it exists?
      EOL
    end
  end
end
