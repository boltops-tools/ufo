module Ufo
  class Info < Ufo::CLI::Base
    include Ufo::AwsServices

    def run
      unless service
        puts no_service_message
        return
      end
      puts "Resources:"
      stack_resources.each do |r|
        puts "#{r.logical_resource_id} - #{r.resource_type}:".color(:green)
        puts "  #{r.physical_resource_id}"
      end
    end

    def no_service_message
      "No stack #{@stack_name.color(:green)} found"
    end

    # Passing in service so method can be used else where.
    def load_balancer(service)
      load_balancer = service.load_balancers.first
      return unless load_balancer

      resp = elb.describe_target_groups(
        target_group_arns: [load_balancer.target_group_arn]
      )
      target_group = resp.target_groups.first
      load_balancer_arn = target_group.load_balancer_arns.first # assume first only

      resp = elb.describe_load_balancers(load_balancer_arns: [load_balancer_arn])
      resp.load_balancers.first
    end
    memoize :load_balancer

    def service
      return unless stack

      service = stack_resources.find { |r| r.resource_type == "AWS::ECS::Service" }
      return unless service # stack is still creating
      arn = service.physical_resource_id
      return unless arn # can be nil for a few seconds while stack is still creating it
      resp = ecs.describe_services(services: [arn], cluster: @cluster)
      resp.services.first
    end
    memoize :service

    def service?
      !!service
    end

    def stack
      find_stack(@stack_name)
    end
    memoize :stack

    def url
      return unless stack

      output = stack.outputs.find do |o|
        o.output_key == "Route53Dns"
      end
      dns_name = output.output_value if output
      return unless dns_name

      ssl = stack_resources.detect.find do |r|
        r.logical_resource_id == "ListenerSsl"
      end

      protocol = ssl ? 'https' : 'http'
      "#{protocol}://#{dns_name}"
    end

    def stack_resources
      resp = cloudformation.describe_stack_resources(stack_name: @stack_name)
      resp.stack_resources
    end
    memoize :stack_resources
  end
end
