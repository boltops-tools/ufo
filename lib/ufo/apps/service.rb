class Ufo::Apps
  class Service
    extend Memoist

    def initialize(service, options)
      @service = service
      @options = options
    end

    def to_a
      [name, task_definition, running, launch_type, dns, ufo?]
    end

    def task_definition
      @service["task_definition"].split('/').last
    end

    def launch_type
      @service["launch_type"]
    end

    def cfn_map
      @cfn_map ||= CfnMap.new(@options).map
    end

    def ufo?
      yes = !!cfn_map[@service["service_name"]]
      yes ? "yes" : "no"
    end

    def name
      full_service_name = @service["service_name"]
      pretty_name = cfn_map[full_service_name]
      if pretty_name
        "#{full_service_name} (#{pretty_name})"
      else
        full_service_name
      end
    end

    def dns
      return 'dns' if ENV['TEST']
      info.load_balancer_dns(@service)
    end

    def running
      @service["running_count"]
    end

    def info
      Ufo::Info.new(@service)
    end
    memoize :info
  end
end
