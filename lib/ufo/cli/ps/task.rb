class Ufo::CLI::Ps
  class Task < Ufo::CLI::Base
    def initialize(options={})
      super
      @task = options[:task] # task response from ecs.list_tasks
    end

    def to_a
      row = [id, name, release, started, status, notes]
      row
    end

    def id
      @task['task_arn'].split('/').last.split('-').first
    end

    def name
      container_overrides = @task.dig("overrides", "container_overrides")
      overrides = container_overrides.first # assume first is one we want
      overrides["name"] if overrides # PENDING wont yet have info
    rescue NoMethodError
      container = @task["containers"].first
      container["name"] if container # PENDING wont yet have info
    end

    def container_instance_arn
      @task['container_instance_arn'].split('/').last
    end

    def release
      @task["task_definition_arn"].split('/').last
    end

    def started
      started = time(@task["started_at"])
      return "PENDING" unless started
      relative_time(started)
    end

    def time(value)
      Time.parse(value.to_s)
    rescue ArgumentError
      nil
    end

    # hide stopped tasks have been stopped for more than 5 minutes
    #  created_at=2018-07-05 21:52:13 -0700,
    #  started_at=2018-07-05 21:52:15 -0700,
    #  stopping_at=2018-07-05 22:03:44 -0700,
    #  stopped_at=2018-07-05 22:03:45 -0700,
    def hide?
      return false if @options[:status] == "stopped"
      started_at = time(@task["started_at"])
      return false unless started_at # edge case when started_at not yet set
      time = Time.now - 60 * Ufo.config.ps.hide_age
      status == "STOPPED" && started_at < time
    end

    def status
      @task["last_status"]
    end

    # Grab all the reasons and surface to user.
    # Even though will make the table output ugly, debugging info merits it.
    #
    #     ufo ps --format json
    #
    def notes
      return unless @task["stopped_reason"]
      notes = []
      notes << "Task Stopped Reason: #{@task["stopped_reason"]}."
      @task.containers.each do |container|
        notes << "Container #{container.name} reason: #{container.reason}" unless container.reason.blank?
      end
      notes.join(" ")
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

    class << self
      def header
        %w[Task Name Release Started Status Notes]
      end
    end
  end
end
