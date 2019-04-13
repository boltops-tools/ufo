class Ufo::Apps
  class Service
    extend Memoist

    def initialize(service, options)
      @service = service
      @options = options
    end

    def to_a
      [name, task_definition, running, launch_type, ufo?]
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
      actual_service_name = @service["service_name"]
      pretty_name = cfn_map[actual_service_name]
      if pretty_name
        "#{actual_service_name} (#{pretty_name})"
      else
        actual_service_name
      end
    end

    def running
      @service["running_count"]
    end

    def dns
      return 'dns' if ENV['TEST']
      elb = info.load_balancer(@service)
      elb.dns_name if elb
    end

    def info
      Ufo::Info.new(@service)
    end
    memoize :info
  end
end
