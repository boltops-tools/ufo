module Ufo
  class Task
    extend Memoist

    include Util
    include AwsService

    def initialize(task_definition, options)
      @task_definition = task_definition
      @options = options
      @cluster = @options[:cluster] || default_cluster
    end

    def run
      puts "Running task_definition: #{@task_definition}".colorize(:green) unless @options[:mute]
      return if @options[:noop]

      task_options = {
        cluster: @cluster,
        task_definition: @task_definition
      }
      task_options = task_options.merge(default_params[:run_task] || {})

      if @options[:command]
        task_options.merge!(overrides: overrides)
        puts "Running task with container overrides."
        puts "Command: #{@options[:command].join(' ')}"
      end

      unless @options[:mute]
        puts "Running task with params:"
        display_params(task_options)
      end

      resp = run_task(task_options)
      unless @options[:mute]
        task_arn = resp.tasks[0].task_arn
        puts "Task ARN: #{task_arn}"
        puts "  aws ecs describe-tasks --tasks #{task_arn} --cluster #{@cluster}"
        cloudwatch_info(task_arn)
      end
    end

    def run_task(options)
      puts "Equivalent aws cli command:"
      puts "  aws ecs run-task --cluster #{@cluster} --task-definition #{options[:task_definition]}".colorize(:green)
      ecs.run_task(options)
    rescue Aws::ECS::Errors::ClientException => e
      if e.message =~ /ECS was unable to assume the role/
        puts "ERROR: #{e.class} #{e.message}".colorize(:red)
        puts "Please double check the executionRoleArn in your task definition."
        exit 1
      else
        raise
      end
    end

  private
    def cloudwatch_info(task_arn)
      config = original_container_definition[:log_configuration]
      container_name = original_container_definition[:name]

      return unless config && config[:log_driver] == "awslogs"

      log_group = config[:options]["awslogs-group"]
      log_stream_prefix = config[:options]["awslogs-stream-prefix"]
      task_id = task_arn.split('/').last
      log_stream = "#{log_stream_prefix}/#{container_name}/#{task_id}"
      # website/web/d473440a-9a0e-4262-a53d-f9e345cf2b7e
      region = `aws configure get region`.strip rescue 'us-east-1'
      url = "https://#{region}.console.aws.amazon.com/cloudwatch/home?region=#{region}#logEventViewer:group=#{log_group};stream=#{log_stream}"

      puts "To see the task output visit CloudWatch:\n  #{url}"
      puts "NOTE: It will take some time for the log to show up because it takes time for the task to start. Run the `aws ecs describe-tasks` above for the task status."
    end

    # only using the overrides to override the container command
    def overrides
      command = @options[:command] # Thor parser ensure this is always an array
      container_definition = original_container_definition
      {
        container_overrides: [
          {
            name: container_definition[:name],
            command: command,
            environment: container_definition[:environment],
          },
        ]
      }
    end

    def original_container_definition
      resp = ecs.list_task_definitions(
        family_prefix: @task_definition,
        sort: "DESC"
      )
      # "arn:aws:ecs:us-east-1:<aws_account_id>:task-definition/wordpress:6",
      last_definition_arn = resp.task_definition_arns.first
      task_name = last_definition_arn.split("/").last
      resp = ecs.describe_task_definition(task_definition: task_name)
      container_definition = resp.task_definition.container_definitions[0].to_h
    end
    memoize :original_container_definition
  end
end
