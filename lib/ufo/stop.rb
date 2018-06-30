module Ufo
  class Stop < Base
    def run
      info = Info.new(@service, @options)
      service = info.service
      @deployments = service.deployments
      if @deployments.size > 1
        stop_old_tasks(service.service_name)
      end
    end

    def stop_old_tasks(service_name)
      # json = JSON.pretty_generate(deployments.map(&:to_h))
      # IO.write("/tmp/deployments.json", json)
      tasks = service_tasks(@cluster, service_name)
      reason = "Ufo #{Ufo::VERSION} has deployed new code and stopping old tasks."
      tasks.each do |task|
        next if task["task_definition_arn"] == latest_deployed_arn
        log "Stopping task #{task["task_arn"]}"
        ecs.stop_task(cluster: @cluster, task: task["task_arn"], reason: reason)
      end
    end

    # latest deployment task definition arn
    def latest_deployed_arn
      latest = @deployments.sort_by do |deployment|
        Time.parse(deployment["created_at"].to_s)
      end.last
      latest["task_definition"]
    end

    def service_tasks(cluster, service_name)
      all_task_arns = ecs.list_tasks(cluster: cluster, service_name: service_name).task_arns
      return [] if all_task_arns.empty?
      ecs.describe_tasks(cluster: cluster, tasks: all_task_arns).tasks
    end

    def log(text)
      path = "#{Ufo.root}/.ufo/log/stop.log"
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'a') do |f|
        f.puts("#{Time.now} #{text}")
      end
      puts text unless @options[:mute]
    end
  end
end
