class Ufo::Ps
  class Task
    def self.header
      %w[Id Name Release Started Status Notes]
    end

    def initialize(task)
      @task = task
    end

    def to_a
      [id, name, release, started, status, notes]
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

    def started_at
      Time.parse(@task["started_at"].to_s)
    rescue ArgumentError
      nil
    end

    # hide stopped tasks that are older than 10 minutes
    def hide?
      status == "STOPPED" && started_at < Time.now - 60 * 10
    end

    def status
      @task["last_status"]
    end

    def notes
      return unless @task["stopped_reason"]

      if @task["stopped_reason"] =~ /Task failed ELB health checks/
        "Failed ELB health check"
      else
        @task["stopped_reason"]
      end
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
