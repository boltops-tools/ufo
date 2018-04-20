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
      data = JSON.parse(IO.read(@template_definition_path))
      data = rubyize_format(data)

      message = "#{data[:family]} task definition registered."
      if @options[:noop]
        message = "NOOP: #{message}"
      else
        register_task_definition(data)
      end

      unless @options[:mute]
        puts "Equivalent aws cli command:"
        file_path = "file://#{@template_definition_path.sub(/^\.\//,'')}"
        puts "  aws ecs register-task-definition --cli-input-json #{file_path}".colorize(:green)
        puts message
      end
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

    # The ruby aws-sdk expects symbols for keys and AWS docs for the task
    # definition uses json camelCase for the keys.  This method transforms
    # the keys to the expected ruby aws-sdk format.
    #
    # One quirk is that the logConfiguration options casing should not be
    # transformed.
    def rubyize_format(original_data)
      data = original_data.to_snake_keys.deep_symbolize_keys

      definitions = data[:container_definitions]
      definitions.each_with_index do |definition, i|
        next unless definition[:log_configuration]
        options = definition[:log_configuration][:options]
        next unless options

        # LogConfiguration options do not get transformed and keep their original
        # structure:
        #   https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ECS/Types/ContainerDefinition.html
        original_definition = original_data["containerDefinitions"][i]
        definition[:log_configuration][:options] = original_definition["logConfiguration"]["options"]
      end

      data
    end
  end
end
