module Ufo
  class Info
    include AwsService
    include Stack::Helper
    include Util
    extend Memoist

    def initialize(service, options)
      @service = service
      @options = options
      @cluster = @options[:cluster] || default_cluster
      @stack_name = adjust_stack_name(@cluster, service)
    end

    def run
      service_name = Ufo.full_sevice_name(@service)
      puts "Service: #{service_name}"
      puts "Service name: #{service.service_name}"
      puts "Status: #{service.status}"
      puts "Running count: #{service.running_count}"
      puts "Desired count: #{service.desired_count}"
      puts "Launch type: #{service.launch_type}"
      puts "Task definition: #{service.task_definition.split('/').last}"
      # not the same response structure as describe_load_balancers
      data = service.load_balancers.first # assume first only
      if data
        load_balancer = load_balancer_info(data.target_group_arn)
        puts "Dns: #{load_balancer.dns_name}"
      end

      puts
      puts "Resources:"
      stack_resources.each do |r|
        # pp r
        puts "#{r.logical_resource_id} - #{r.resource_type}:"
        puts "  #{r.physical_resource_id}"
      end
    end

    def load_balancer_info(target_group_arn)
      resp = elb.describe_target_groups(target_group_arns: [target_group_arn])
      target_group = resp.target_groups.first
      load_balancer_arn = target_group.load_balancer_arns.first # assume first only

      resp = elb.describe_load_balancers(load_balancer_arns: [load_balancer_arn])
      resp.load_balancers.first
    end

    def service
      stack = find_stack(@stack_name)
      return unless stack

      service = stack_resources.find { |r| r.resource_type == "AWS::ECS::Service" }
      arn = service.physical_resource_id
      resp = ecs.describe_services(services: [arn], cluster: @cluster)
      resp.services.first
    end
    memoize :service

    def stack_resources
      resp = cloudformation.describe_stack_resources(stack_name: @stack_name)
      resp.stack_resources
    end
    memoize :stack_resources
  end
end
