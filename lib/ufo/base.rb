module Ufo
  class Base
    extend Memoist
    include Stack::Helper

    def initialize(service, options={})
      @service = switch_current(service)
      @options = options

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
No #{@service.color(:green)} found.
No CloudFormation stack named #{@stack_name} found.
Are sure it exists?
      EOL
    end
  end
end
