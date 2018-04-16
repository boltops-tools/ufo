module Ufo
  class Task
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
      task_options = task_options.merge(default_params[:run_task])

      if @options[:command]
        task_options.merge!(overrides: overrides)
        puts "Running task with container overrides."
        puts "Command: #{@options[:command].join(' ')}"
      end

      display_params(task_options)
      resp = ecs.run_task(task_options)
      puts "Task ARN: #{resp.tasks[0].task_arn}" unless @options[:mute]
    end

  private
    # only using the overrides to override the container command
    def overrides
      command = @options[:command] # Thor parser ensure this is always an array
      container_definition = get_original_container_definition
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

    def get_original_container_definition
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
  end
end
