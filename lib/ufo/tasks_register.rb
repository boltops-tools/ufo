require 'plissken' # Hash#to_snake_keys
require 'json'

module Ufo
  class TasksRegister
    include AwsServices

    def self.register(task_name, options={})
      project_root = options[:project_root] || '.'
      Dir.glob("#{project_root}/ufo/output/*").each do |path|
        if task_name == :all or path.include?(task_name)
          task_register = TasksRegister.new(path, options)
          task_register.register
        end
      end
    end

    def initialize(template_definition_path, options={})
      @template_definition_path = template_definition_path
      @options = options
    end

    # aws ecs register-task-definition --cli-input-json file://ufo/output/hi-web-prod.json
    def register
      data = JSON.parse(IO.read(@template_definition_path), symbolize_names: true)
      data = data.to_snake_keys
      data = fix_log_configuation_option(data)
      message = "#{data[:family]} task definition registered."
      if @options[:noop]
        message = "NOOP: #{message}"
      else
        ecs.register_task_definition(data)
      end
      puts message unless @options[:mute]
    end

    # LogConfiguration requires a string with dashes as the keys
    # https://docs.aws.amazon.com/sdkforruby/api/Aws/ECS/Client.html
    def fix_log_configuation_option(data)
      definitions = data[:container_definitions]
      definitions.each do |definition|
        next unless definition[:log_configuration]
        options = definition[:log_configuration][:options]
        options["awslogs-group"] = options.delete(:awslogs_group)
        options["awslogs-region"] = options.delete(:awslogs_region)
        options["awslogs-stream-prefix"] = options.delete(:awslogs_stream_prefix)
      end
      data
    end
  end
end
