module Ufo
  class Base
    extend Memoist
    include Stack::Helper

    def initialize(service, options)
      @service = switch_current(service)
      @options = options
      @cluster = @options[:cluster] || default_cluster
      @stack_name = adjust_stack_name(@cluster, @service)
    end

    def switch_current(service)
      return service if service != :current

      service = Current.service
      return service if service

      puts <<-EOL
ERROR: service must be specified at the cli:
    ufo #{ARGV.first} SERVICE
Or you can set a current service must be set with:
    ufo current SERVICE
EOL
      exit 1
      # if want to display full help menu:
      # Ufo::CLI.start(ARGV + ["-h"])
    end
  end
end
