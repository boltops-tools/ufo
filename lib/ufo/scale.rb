module Ufo
  class Scale < Base
    delegate :service, to: :info

    def initialize(service, count, options={})
      super(service, options)
      @count = count
    end

    def info
      Info.new(@service, @options)
    end
    memoize :info

    def update
      unless service_exists?
        puts "Unable to find the #{@full_service_name.colorize(:green)} service on the #{@cluster.colorize(:green)} cluster."
        puts "Are you sure you are trying to scale the right service on the right cluster?"
        exit
      end
      ecs.update_service(
        service: service.service_name,
        cluster: @cluster,
        desired_count: @count
      )
      puts "Scale #{@full_service_name.colorize(:green)} service in #{@cluster.colorize(:green)} cluster to #{@count}" unless @options[:mute]
    end

    def service_exists?
      !!service
    end
  end
end
