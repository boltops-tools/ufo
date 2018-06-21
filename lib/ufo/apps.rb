require 'text-table'

module Ufo
  class Apps
    extend Memoist
    include Stack::Helper

    def initialize(options)
      @options = options
      @cluster = @options[:cluster] || default_cluster
    end

    def list
      begin
        resp = ecs.list_services(cluster: @cluster)
      rescue Aws::ECS::Errors::ClusterNotFoundException => e
        puts "ECS cluster #{@cluster.colorize(:green)} not found."
        exit 1
      end
      arns = resp.service_arns

      if arns.empty?
        puts "No ecs services found in the #{@cluster.colorize(:green)} cluster."
        return
      end

      resp = ecs.describe_services(services: arns, cluster: @cluster)
      display_info(resp)
      # IO.write("/tmp/services.json", JSON.pretty_generate(resp.to_h))
    end

    # TODO: logic to check cloudformation to get the pretty service name
    def display_info(resp)
      table = Text::Table.new
      table.head = ["Service Name", "Task Definition", "Running", "Launch type", "Dns", "Ufo?"]
      resp["services"].each do |s|
        table.rows << Service.new(s, @options).to_a
      end
      puts table
    end

    class CfnInfo
      extend Memoist
      include Stack::Helper

      def initialize(options = {})
        @options = options
        @cluster = @options[:cluster] || default_cluster
        @map = {}
      end

      def map
        return @map if @populated

        populate_map!
        @populated = true
        @map
      end

      def summaries
        filter = %w[
          UPDATE_COMPLETE
          CREATE_COMPLETE
          UPDATE_ROLLBACK_COMPLETE
          UPDATE_IN_PROGRESS
          UPDATE_COMPLETE_CLEANUP_IN_PROGRESS
          UPDATE_ROLLBACK_IN_PROGRESS
          UPDATE_ROLLBACK_FAILED
          UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS
          REVIEW_IN_PROGRESS
        ]

        summaries = []
        next_token = true
        while next_token
          resp = cloudformation.list_stacks(stack_status_filter: filter)
          summaries += resp.stack_summaries
          next_token = resp.next_token
        end

        # look for stacks that beling that ufo create
        summaries.select do |s|
          s.template_description =~ /Ufo ECS stack/
        end
      end
      memoize :summaries

      def populate_map!
        summaries.each do |summary|
          resp = cloudformation.describe_stack_resources(stack_name: summary.stack_name)
          ecs_resource = resp.stack_resources.find do |resource|
            resource.logical_resource_id == "Ecs"
          end
          # Example: "PhysicalResourceId": "arn:aws:ecs:us-east-1:160619113767:service/dev-hi-web-Ecs-1HRL8Y9F4D1CR"
          ecs_service_name = ecs_resource.physical_resource_id.split('/').last
          @map[ecs_service_name] = stack_name_to_service_name(summary.stack_name)
        end
      end

      def stack_name_to_service_name(stack_name)
        stack_name.sub("#{@cluster}-",'')
      end
    end

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
        @cfn_info ||= CfnInfo.new(@options)
        @cfn_info.map
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
end
