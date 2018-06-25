class Ufo::Stack
  class Context
    extend Memoist
    include Helper

    def initialize(options)
      @options = options
      @task_definition = options[:task_definition]
      @service = options[:service]
      # no need to adjust @cluster or @stack_name because it was adjusted in Stack#initialize
      @cluster = options[:cluster]
      @stack_name = options[:stack_name]

      @stack = options[:stack]
      @new_stack = !@stack
    end

    def scope
      scope = Ufo::TemplateScope.new(Ufo::DSL::Helper.new, nil)
      # Add additional variable to scope for CloudFormation template.
      # Dirties the scope but needed.
      vars = {
        cluster: @cluster,
        stack_name: @stack_name, # used in custom_properties
        pretty_service_name: Ufo.pretty_service_name(@service),
        container: container,
        # elb options remember that their 'state'
        create_elb: create_elb?, # helps set Ecs DependsOn
        elb_type: elb_type,
        subnet_mappings: subnet_mappings,
        create_route53: create_elb? && network[:dns] && network[:dns][:name],
      }
      # puts "vars:".colorize(:cyan)
      # pp vars
      scope.assign_instance_variables(vars)
      scope
    end
    memoize :scope

    def container
      resp = ecs.describe_task_definition(task_definition: @task_definition)
      task_definition = resp.task_definition

      container_def = task_definition["container_definitions"].first
      mappings = container_def["port_mappings"]
      if mappings
        map = mappings.first
        port = map["container_port"]
      end
      requires_compatibilities = task_definition["requires_compatibilities"]
      fargate = requires_compatibilities && requires_compatibilities == ["FARGATE"]
      network_mode = task_definition["network_mode"]

      {
        name: container_def["name"],
        port: port,
        fargate: fargate,
        network_mode: network_mode,
      }
    end
    memoize :container

    def create_elb?
      create_elb, _ = elb_options
      create_elb == "true" # convert to boolean
    end

    # if --elb is not set at all, so it's nil. Thhen it defaults to creating the
    # load balancer if the ecs service has a container name "web".
    #
    # --elb '' - wont crete an elb
    # --elb 'auto' - creates an elb
    # --elb arn:... - wont create elb and use the existing target group
    #
    def elb_options
      case @options[:elb]
      when "auto", "true", "yes"
        create_elb = "true"
        elb_target_group = ""
      when "false", "0", "no"
        create_elb = "false"
        elb_target_group = ""
      when /^arn:aws:elasticloadbalancing.*targetgroup/
        create_elb = "false"
        elb_target_group = @options[:elb]
      when "", nil
        create_elb, elb_target_group = default_elb_options
      else
        puts "Invalid --elb option provided: #{@options[:elb].inspect}".colorize(:red)
        puts "Exiting."
        exit 1
      end
      [create_elb, elb_target_group]
    end

    def default_elb_options
      # cannot use :use_previous_value because need to know the create_elb value to
      # compile a template with the right DependsOn for the Ecs service
      unless @new_stack
        create_elb = get_parameter_value(@stack, "CreateElb")
        elb_target_group = get_parameter_value(@stack, "ElbTargetGroup")
        return [create_elb, elb_target_group]
      end

      # default is to create the load balancer is if container name is web
      # and no --elb option is provided
      create_elb = "true" if container[:name] == "web"
      elb_target_group = ""
      [create_elb, elb_target_group]
    end

    def get_parameter_value(stack, key)
      param = stack.parameters.find do |p|
        p.parameter_key == key
      end
      param.parameter_value
    end

    def reset_empty_eip_ids?
      # reset and remove eip allocation ids check
      @options[:elb_eip_ids] && @options[:elb_eip_ids].detect { |x| [' ', 'empty'].include?(x) }
    end

    def subnet_mappings
      return [] if reset_empty_eip_ids?

      elb_eip_ids = normalize_elb_eip_ids
      return build_subnet_mappings!(elb_eip_ids) unless elb_eip_ids.empty?

      unless @new_stack
        elb_eip_ids = get_parameter_value(@stack, "ElbEipIds").split(',')
        build_subnet_mappings(elb_eip_ids)
      end
    end

    def normalize_elb_eip_ids
      elb_eip_ids = @options[:elb_eip_ids] || []
      elb_eip_ids.uniq!
      elb_eip_ids
    end

    # Returns string, used as CloudFormation parameter.
    def elb_eip_ids
      return '' if reset_empty_eip_ids?

      elb_eip_ids = normalize_elb_eip_ids
      return elb_eip_ids.join(',') unless elb_eip_ids.empty?

      unless @new_stack
        return get_parameter_value(@stack, "ElbEipIds")
      end

      ''
    end

    def build_subnet_mappings!(allocations)
      unless allocations.size == network[:elb_subnets].size
        # puts "caller:".colorize(:cyan)
        # puts caller
        puts "ERROR: The allocation_ids must match in length to the subnets.".colorize(:red)
        puts "Please double check that .ufo/settings/network/#{settings[:network_profile]} has the same number of subnets as the eip allocation ids are you specifying."
        subnets = network[:elb_subnets]
        puts "Conigured subnets: #{subnets.inspect}"
        puts "Specified allocation ids: #{allocations.inspect}"
        exit 1
      end

      build_subnet_mappings(allocations)
    end

    def build_subnet_mappings(allocations)
      mappings = []
      allocations.sort.each_with_index do |allocation_id, i|
        mappings << [allocation_id, network[:elb_subnets][i]]
      end
      mappings
    end

    def elb_type
      # if option explicitly specified then change the elb type
      return @options[:elb_type] if @options[:elb_type]
      # user is trying to create a network load balancer if --elb-eip-ids is used
      elb_eip_ids = normalize_elb_eip_ids
      if !elb_eip_ids.empty?
        return "network"
      end

      # if not explicitly set, new stack will defeault to application load balancer
      if @new_stack # default for new stack
        return "application"
      end

      # find existing load balancer for type
      resp = cloudformation.describe_stack_resources(stack_name: @stack_name)
      resources = resp.stack_resources
      elb_resource = resources.find do |resource|
        resource.logical_resource_id == "Elb"
      end

      # In the case when stack exists and there is no elb resource, the elb type
      # doesnt really matter because the elb wont be created since the CreateElb
      # parameter is set to false. The elb type only needs to be set for the
      # template to validate.
      return "application" unless elb_resource

      resp = elb.describe_load_balancers(load_balancer_arns: [elb_resource.physical_resource_id])
      load_balancer = resp.load_balancers.first
      load_balancer.type
    end
    memoize :elb_type

    def network
      Ufo::Setting::Network.new(settings[:network_profile]).data
    end
    memoize :network

    def settings
      Ufo.settings
    end

  end
end
