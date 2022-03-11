class Ufo::CLI
  class Exec < Base
    def run
      check_install!
      stack = info.stack
      unless stack
        logger.error "Stack not found: #{@stack_name}".color(:red)
        exit 1
      end

      service = info.service
      unless service # brand new deploy
        logger.error "ECS Service not yet available".color(:red)
        logger.info "Try again in a little bit"
        exit 1
      end

      running = service_tasks.select do |task|
        task.last_status == "RUNNING"
      end
      if running.empty?
        logger.info "No running tasks found to exec into"
        return
      end

      tasks = running.sort_by { |t| t.started_at }
      task = tasks.last # most recent

      task_name = task.task_arn.split('/').last
      execute_command(
        cluster: "#{@cluster}",
        task: task_name,
        container: container(task), # only required if multiple containers in a task
        interactive: true,
        command: command
      )
    end

    def container(task)
      return @options[:container] if @options[:container]
      containers = task.containers
      container = containers.find do |c|
        c.name == @options[:role]
      end
      container ||= containers.first  # assume first task if not roles match
      container.name if container
    end

    def execute_command(options={})
      args = options.inject('') do |args, (k,v)|
        arg = k == :interactive ? "--#{k}" : "--#{k} #{v}"
        args += " #{arg}"
      end
      sh "aws ecs execute-command#{args}"
    end

    def service_tasks
      service_name = info.service.service_name
      all_task_arns = ecs.list_tasks(cluster: @cluster, service_name: service_name).task_arns
      return [] if all_task_arns.empty?
      ecs.describe_tasks(cluster: @cluster, tasks: all_task_arns).tasks
    end

    def sh(command)
      puts "=> #{command}"
      Kernel.exec command
    end

    def command
      @options[:command] || Ufo.config.exec.command
    end

    def check_install!
      check_session_manager_plugin!
      check_aws_cli!
    end

    def check_session_manager_plugin!
      installed = system "type session-manager-plugin > /dev/null 2>&1"
      return if installed
      logger.error "ERROR: The Session Manager plugin required to use ufo exec".color(:red)
      exit 1
    end

    def check_aws_cli!
      installed = system "type aws > /dev/null 2>&1"
      return if installed
      logger.error "ERROR: aws cli is required to use ufo exec".color(:red)
      exit 1
    end
  end
end
