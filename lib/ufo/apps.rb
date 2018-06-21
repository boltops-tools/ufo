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
        table.rows << Service.new(s).to_a
      end
      puts table
    end

    class Service
      extend Memoist

      def initialize(service)
        @service = service
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

      def ufo?
        "yes"
      end

      def name
        @service["service_name"]
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
