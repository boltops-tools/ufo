require 'thor'
require 'ufo/command'
require 'active_support/core_ext/string'

module Ufo
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :mute, type: :boolean
    class_option :noop, type: :boolean
    class_option :project_root, type: :string, default: '.'
    class_option :cluster, desc: "Cluster.  Overrides ufo/settings.yml."

    desc "docker [ACTION]", "docker related tasks"
    long_desc Help.text(:docker)
    subcommand "docker", Docker

    desc "tasks [ACTION]", "task definition related tasks"
    long_desc Help.text(:tasks)
    subcommand "tasks", Tasks

    desc "init", "setup initial ufo files"
    option :image, type: :string, required: true, desc: "Docker image name without the tag. Example: tongueroo/hi. Configures ufo/settings.yml"
    option :app, type: :string, required: true, desc: "App name. Preferably one word. Used in the generated ufo/task_definitions.rb."
    long_desc Help.text(:init)
    def init
      Init.new(options).setup
    end

    # common options to ship and ships command
    ship_options = Proc.new do
      option :task, desc: "ECS task name, to override the task name convention."
      option :target_group, desc: "ELB Target Group ARN."
      option :target_group_prompt, type: :boolean, desc: "Enable Target Group ARN prompt", default: true
      option :docker, type: :boolean, desc: "Enable docker build and push", default: true
      option :tasks, type: :boolean, desc: "Enable tasks build and register", default: true
      option :wait, type: :boolean, desc: "Wait for deployment to complete", default: false
      option :pretty, type: :boolean, default: true, desc: "Pretty format the json for the task definitions"
      option :stop_old_tasks, type: :boolean, default: false, desc: "Stop old tasks after waiting for deploying to complete"
      option :ecr_keep, type: :numeric, desc: "ECR specific cleanup of old images.  Specifies how many images to keep.  Only runs if the images are ECR images. Defaults to keeping all the images."
    end

    desc "ship [SERVICE]", "builds and ships container image to the ECS service"
    long_desc Help.text(:ship)
    ship_options.call
    def ship(service)
      builder = build_docker

      task_definition = options[:task] || service # convention
      Tasks::Builder.register(task_definition, options) if options[:tasks]
      LogGroup.new(task_definition, options).create
      ship = Ship.new(service, task_definition, options)
      ship.deploy

      cleanup(builder.image_name)
    end

    desc "ships [LIST-OF-SERVICES]", "builds and ships same container image to multiple ECS services"
    long_desc Help.text(:ships)
    ship_options.call
    def ships(*services)
      builder = build_docker

      services.each_with_index do |service|
        service_name, task_defintion_name = service.split(':')
        task_definition = task_defintion_name || service_name # convention
        Tasks::Builder.register(task_definition, options) if options[:tasks]
        LogGroup.new(task_definition, options).create
        ship = Ship.new(service, task_definition, options)
        ship.deploy
      end

      cleanup(builder.image_name)
    end

    desc "task [TASK_DEFINITION]", "runs a one time task"
    long_desc Help.text(:task)
    option :docker, type: :boolean, desc: "Enable docker build and push", default: true
    option :command, type: :array, desc: "Override the command used for the container"
    def task(task_definition)
      Docker::Builder.build(options)
      Tasks::Builder.register(task_definition, options)
      Task.new(task_definition, options).run
    end

    desc "destroy [SERVICE]", "destroys the ECS service"
    long_desc Help.text(:destroy)
    option :sure, type: :boolean, desc: "By pass are you sure prompt."
    def destroy(service)
      task_definition = options[:task] || service # convention
      Destroy.new(service, options).bye
    end

    desc "scale [SERVICE] [COUNT]", "scale the ECS service"
    long_desc Help.text(:scale)
    def scale(service, count)
      Scale.new(service, count, options).update
    end

    desc "version", "Prints version number of installed ufo"
    def version
      puts VERSION
    end

    desc "commands", "Prints all commands"
    def commands
      commands = CLI.all_commands.reject do |k,v|
        v.is_a?(Thor::HiddenCommand)
      end
      puts commands.keys
    end

    desc "completions *PARAMS", "puts auto completion words"
    def completions(*params)
      return if params.size == 0

      current_command = params[0]

      # puts "current_command: #{current_command}"
      arity = Ufo::CLI.instance_method(current_command).arity
      if params.size > arity
        # puts "here1"
        method_options = CLI.all_commands[current_command].options.keys
        class_options = Ufo::CLI.class_options.keys
        all_options = method_options + class_options
        puts all_options.map { |o| "--#{o.to_s.dasherize}" }
      else
        # puts "here2"
        method_params = Ufo::CLI.instance_method(current_command).parameters.map(&:last)
        # puts "method_params #{method_params.inspect}"
        # puts "params.size #{params.size}"
        offset = params.size - 1
        # puts "offset #{offset}"
        puts method_params[offset..-1].first.upcase
      end
    end

    no_tasks do
      def build_docker
        builder = Docker::Builder.new(options)
        if options[:docker]
          builder.build
          builder.push
        end
        builder
      end

      def cleanup(image_name)
        return unless options[:docker]

        Docker::Cleaner.new(image_name, options).cleanup
        Ecr::Cleaner.new(image_name, options).cleanup
      end
    end
  end
end
