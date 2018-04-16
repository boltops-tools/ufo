require 'plissken' # Hash#to_snake_keys
require 'json'

module Ufo
  class Tasks::Register
    include Util
    include AwsService

    def self.register(task_name, options={})
      Dir.glob("#{Ufo.root}/.ufo/output/*").each do |path|
        if task_name == :all or path.include?(task_name)
          task_register = Tasks::Register.new(path, options)
          task_register.register
        end
      end
    end

    def initialize(template_definition_path, options={})
      @template_definition_path = template_definition_path
      @options = options
    end

    # aws ecs register-task-definition --cli-input-json file://.ufo/output/hi-web-prod.json
    def register
      data = JSON.parse(IO.read(@template_definition_path), symbolize_names: true)
      data = data.to_snake_keys
      data = fix_log_configuation_option(data)
      message = "#{data[:family]} task definition registered."
      if @options[:noop]
        message = "NOOP: #{message}"
      else
        register_task_definition(data)
      end
      puts message unless @options[:mute]
    end

    def register_task_definition(data)
      if ENV["UFO_SHOW_REGISTER_TASK_DEFINITION"]
        puts "Registering task definition with:"
        display_params(data)
      end

      ecs.register_task_definition(data)
    rescue Aws::ECS::Errors::ClientException => e
      if e.message =~ /No Fargate configuration exists for given values/
        puts "ERROR: #{e.message}".colorize(:red)
        puts "Configured values are: cpu #{data[:cpu]} memory #{data[:memory]}"
        puts "Check that the cpu and memory values are a supported combination by Fargate."
        puts "More info: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
        exit 1
      else
        raise
      end
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
