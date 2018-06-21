require 'text-table'

module Ufo
  class Ps < Base
    delegate :service, to: :info

    def run
      unless service
        puts no_service_message
        return
      end

      puts "=> Service: #{@full_service_name}"
      puts "   Service name: #{service.service_name}"
      puts "   Status: #{service.status}"
      puts "   Running count: #{service.running_count}"
      puts "   Desired count: #{service.desired_count}"
      puts "   Launch type: #{service.launch_type}"
      puts "   Task definition: #{service.task_definition.split('/').last}"
      if task_arns.empty?
        puts "There are 0 running tasks."
      else
        resp = ecs.describe_tasks(tasks: task_arns, cluster: @cluster)
        display_info(resp)
      end
    end

    def task_arns
      threads, results = [], {}
      statuses = %w[RUNNING PENDING STOPPED]
      statuses.each do |status|
        threads << Thread.new do
          resp = ecs.list_tasks(service_name: service.service_name, cluster: @cluster, desired_status: status)
          results[status] = resp.task_arns
        end
      end
      threads.map(&:join)
      results.values.flatten.uniq
    end

    def display_info(resp)
      table = Text::Table.new
      table.head = %w[ID NAME RELEASE STARTED STATUS]
      resp["tasks"].each do |t|
        table.rows << Task.new(t).info
      end
      puts table

      pp service["events"][0..3]
    end

    class Task
      def initialize(task)
        @task = task
      end

      def info
        [id, name, release, started, status]
      end

      def id
        @task['task_arn'].split('/').last.split('-').first
      end

      def name
        @task["overrides"]["container_overrides"].first["name"]
      rescue NoMethodError
        @task["containers"].first["name"]
      end

      def release
        @task["task_definition_arn"].split('/').last
      end

      def started
        started = Time.parse(@task["started_at"].to_s)
        relative_time(started)
      rescue ArgumentError
        "PENDING"
      end

      def status
        @task["last_status"]
      end

      # https://stackoverflow.com/questions/195740/how-do-you-do-relative-time-in-rails/195894
      def relative_time(start_time)
        diff_seconds = Time.now - start_time
        case diff_seconds
          when 0 .. 59
            "#{diff_seconds.to_i} seconds ago"
          when 60 .. (3600-1)
            "#{(diff_seconds/60).to_i} minutes ago"
          when 3600 .. (3600*24-1)
            "#{(diff_seconds/3600).to_i} hours ago"
          when (3600*24) .. (3600*24*30)
            "#{(diff_seconds/(3600*24)).to_i} days ago"
          else
            start_time.strftime("%m/%d/%Y")
        end
      end
    end
  end
end
