module Ufo
  class Task
    include Defaults
    include AwsServices

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
      task_options.merge!(overrides: overrides) if @options[:command]
      resp = ecs.run_task(task_options)
      puts "Task ARN: #{resp.tasks[0].task_arn}" unless @options[:mute]
    end

  private
    # only using the overrides to override the container command
    def overrides
      command = @options[:command]
      command = eval(command) if command.include?('[') # command is in Array form
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
