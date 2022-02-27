# Use to automatically create the CloudWatch group.
# For some reason creating ECS does do this by default.
module Ufo
  class LogGroup < Ufo::CLI::Base
    include Ufo::AwsServices

    def create
      logger.debug "Ensuring log group for #{@task_definition.name.color(:green)} task definition exists"
      return if @options[:noop]
      return if @options[:rollback] # dont need to create log group because previously deployed

      check_task_definition_exists!
      task_def = JSON.load(IO.read(task_def_path))
      task_def["containerDefinitions"].each do |container_def|
        begin
          log_group_name = container_def["logConfiguration"]["options"]["awslogs-group"]
          logger.debug "Log group name: #{log_group_name}"
        rescue NoMethodError
          # silence when the logConfiguration is not specified
        end

        create_log_group(log_group_name) if log_group_name
      end
    end

    def create_log_group(log_group_name)
      resp = cloudwatchlogs.describe_log_groups(log_group_name_prefix: log_group_name)
      exists = resp.log_groups.find { |lg| lg.log_group_name == log_group_name }
      cloudwatchlogs.create_log_group(log_group_name: log_group_name) unless exists
    end

    def task_def_path
      "#{Ufo.root}/.ufo/output/task_definition.json"
    end

    def check_task_definition_exists!
      return if File.exist?(task_def_path)
      logger.error "ERROR: Unable to find the task definition at #{task_def_path}.".color(:red)
      logger.error <<~EOL
          Please double check that it was built correctly with:

              ufo build

      EOL
      exit 1
    end
  end
end
