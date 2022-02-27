class Ufo::CLI
  class Stop < Base
    def run
      service = info.service
      return unless service # brand new deploy

      @deployments = service.deployments
      if @deployments.size >= 1
        stop(service.service_name)
      end
    end

    def stop(service_name)
      tasks = service_tasks(service_name)
      show(tasks, preview: true) unless @options[:yes]
      sure?
      tasks.each do |task|
        if @options[:stop_old_tasks]
          next if task["task_definition_arn"] == latest_deployed_arn
        end
        logger.debug "stop task #{task["task_arn"]}"
        meth = "stop_task"
        ecs.stop_task(cluster: @cluster, task: task["task_arn"], reason: "stop by ufo")
      end
      logger.info "Stopping tasks"
      show(tasks, preview: false) if @options[:yes]
    end

    def show(tasks, preview: true)
      logger.info "Will stop the following tasks:" if preview
      ps = Ps.new(@options)
      ps.display_tasks(tasks)
    end

    # latest deployment task definition arn
    def latest_deployed_arn
      latest = @deployments.sort_by do |deployment|
        Time.parse(deployment["created_at"].to_s)
      end.last
      latest["task_definition"]
    end

    def service_tasks(service_name)
      all_task_arns = ecs.list_tasks(cluster: @cluster, service_name: service_name).task_arns
      return [] if all_task_arns.empty?
      ecs.describe_tasks(cluster: @cluster, tasks: all_task_arns).tasks
    end
  end
end
