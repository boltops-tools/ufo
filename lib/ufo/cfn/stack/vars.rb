class Ufo::Cfn::Stack
  class Vars < Ufo::Cfn::Base
    attr_reader :stack_name
    def initialize(options={})
      super
      @cluster = options[:cluster].dup # Thor options are frozen, we thaw it because CustomProperties#substitute_variables does a sub!
      @stack_name = options[:stack_name] || [Ufo.app, @task_definition.role, Ufo.env].join('-')
      @stack = options[:stack]
      @new_stack = !@stack
    end

    def values
      {
        cluster: @cluster,
        stack_name: @stack_name, # used in custom_properties
        container: container,
        # to reconstruct TaskDefinition in the CloudFormation template
        task_definition: @task_definition,
        rollback_task_definition: @options[:rollback_task_definition],
        # elb options remember that their 'state'
        create_elb: create_elb?, # helps set Ecs DependsOn
        elb_type: elb_type,
        create_route53: create_elb? && dns_configured?,
        default_target_group_protocol: default_target_group_protocol,
        default_listener_protocol: default_listener_protocol,
        default_listener_ssl_protocol: default_listener_ssl_protocol,
        create_listener_ssl: create_listener_ssl?,
      }
    end

    def dns_configured?
      !!Ufo.config.dns.domain || !!Ufo.config.dns.name
    end

    def default_listener_protocol
      port = Ufo.config.elb.port
      if elb_type == 'network'
        port == 443 ? 'TLS' : 'TCP'
      else
        port == 443 ? 'HTTPS' : 'HTTP'
      end
    end

    def default_listener_ssl_protocol
      elb_type == 'network' ? 'TLS' : 'HTTPS'
    end

    def default_target_group_protocol
      elb_type == 'network' ? 'TCP' : 'HTTP'
    end

    # if the configuration is set to anything then enable it
    def create_listener_ssl?
      Ufo.config.elb.ssl.enabled
    end

    def create_elb?
      elb = Ufo.config.elb
      if elb.enabled.to_s == "auto"
        container[:name] == "web" # convention
      else
        elb.enabled # true or false
      end
    end

    def container
      task_definition = Builder::Resources::TaskDefinition::Reconstructor.new(@task_definition, @options[:rollback]).reconstruct

      container_def = task_definition["ContainerDefinitions"].first
      requires_compatibilities = task_definition["RequiresCompatibilities"]
      fargate = requires_compatibilities && requires_compatibilities == ["FARGATE"]
      network_mode = task_definition["NetworkMode"]

      mappings = container_def["PortMappings"] || []
      unless mappings.empty?
        port = mappings.first["ContainerPort"]
      end

      result =  {
        name: container_def["Name"],
        fargate: fargate,
        network_mode: network_mode, # awsvpc, bridge, etc
      }
      result[:port] = port if port
      result
    end
    memoize :container

    def get_parameter_value(stack, key)
      param = stack.parameters.find do |p|
        p.parameter_key == key
      end
      param.parameter_value if param
    end

    def elb_type
      elb_type = Ufo.config.elb.type
      return elb_type if elb_type

      # user is trying to create a network load balancer if subnet_mappings used
      subnet_mappings = Ufo.config.elb.subnet_mappings
      if subnet_mappings.empty?
        "application" # default
      else
        "network"
      end
    end
    memoize :elb_type
  end
end
