class Ufo::Ps
  class Task
    def self.header
      header = %w[Id Name Release Started Status Notes]
      header << "Container Instance" if extra_columns
      header
    end

    def initialize(task)
      @task = task
    end

    def to_a
      row = [id, name, release, started, status, notes]
      row << container_instance_arn if extra_columns
      row
    end

    def id
      @task['task_arn'].split('/').last.split('-').first
    end

    def name
      @task["overrides"]["container_overrides"].first["name"]
    rescue NoMethodError
      @task["containers"].first["name"]
    end

    def container_instance_arn
      @task['container_instance_arn']
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
     # started_at=2018-07-05 21:52:15 -0700,
     # stopping_at=2018-07-05 22:03:44 -0700,
     # stopped_at=2018-07-05 22:03:45 -0700,
    def hide?
      stopped_at = time(@task["stopped_at"])
      status == "STOPPED" && stopped_at < Time.now - 60 * 5
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

    @@extra_columns = false
    def self.extra_columns=(val)
      @@extra_columns = val
    end

    def self.extra_columns
      @@extra_columns
    end

    def extra_columns
      self.class.extra_columns
    end
  end
end
