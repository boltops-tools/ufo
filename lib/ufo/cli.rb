require 'thor'
require 'ufo/command'

module Ufo
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :mute, type: :boolean
    class_option :noop, type: :boolean
    class_option :cluster, desc: "Cluster.  Overrides ufo/settings.yml."

    desc "network SUBCOMMAND", "network subcommands"
    long_desc Help.text(:network)
    subcommand "network", Network

    desc "docker SUBCOMMAND", "docker subcommands"
    long_desc Help.text(:docker)
    subcommand "docker", Docker

    desc "tasks SUBCOMMAND", "task definition subcommands"
    long_desc Help.text(:tasks)
    subcommand "tasks", Tasks

    long_desc Help.text(:init)
    Init.cli_options.each do |args|
      option *args
    end
    register(Init, "init", "init", "Set up initial ufo files.")

    # common options to deploy. ship, and ships command
    ship_options = Proc.new do
      option :task, desc: "ECS task name, to override the task name convention."
      option :target_group, desc: "ELB Target Group ARN."
      option :target_group_prompt, type: :boolean, desc: "Enable Target Group ARN prompt", default: true
      option :wait, type: :boolean, desc: "Wait for deployment to complete", default: false
      option :pretty, type: :boolean, default: true, desc: "Pretty format the json for the task definitions"
      option :stop_old_tasks, type: :boolean, default: false, desc: "Stop old tasks after waiting for deploying to complete"
      option :ecr_keep, type: :numeric, desc: "ECR specific cleanup of old images.  Specifies how many images to keep.  Only runs if the images are ECR images. Defaults keeps all images."
      option :elb, desc: "ELB balancer profile to use"
    end

    desc "deploy SERVICE", "Deploy task definition to ECS service without re-building the definition."
    long_desc Help.text(:deploy)
    ship_options.call
    def deploy(service=:current)
      service = service == :current ? Current.service! : service
      task_definition = options[:task] || service # convention
      Tasks::Register.register(task_definition, options)
      ship = Ship.new(service, options.merge(task_definition: task_definition))
      ship.deploy
    end

    desc "ship SERVICE", "Builds and ships container image to the ECS service."
    long_desc Help.text(:ship)
    ship_options.call
    def ship(service=:current)
      builder = build_docker

      service = service == :current ? Current.service! : service
      task_definition = options[:task] || service # convention
      Tasks::Builder.ship(task_definition, options)
      ship = Ship.new(service, options.merge(task_definition: task_definition))
      ship.deploy

      cleanup(builder.image_name)
    end

    desc "ships [LIST_OF_SERVICES]", "Builds and ships same container image to multiple ECS services."
    long_desc Help.text(:ships)
    ship_options.call
    def ships(*services)
      builder = build_docker

      services.each_with_index do |service|
        service_name, task_definition_name = service.split(':')
        task_definition = task_definition_name || service_name # convention
        Tasks::Builder.ship(task_definition, options)
        ship = Ship.new(service, options.merge(task_definition: task_definition))
        ship.deploy
      end

      cleanup(builder.image_name)
    end

    desc "task TASK_DEFINITION", "Run a one-time task."
    long_desc Help.text(:task)
    option :docker, type: :boolean, desc: "Enable docker build and push", default: true
    option :command, type: :array, aliases: 'c', desc: "Override the command used for the container"
    def task(task_definition)
      Docker::Builder.build(options) if @options[:docker]
      Tasks::Builder.ship(task_definition, options)
      Task.new(task_definition, options).run
    end

    desc "cancel SERVICE", "Cancel creation or update of the ECS service."
    long_desc Help.text(:cancel)
    option :sure, type: :boolean, desc: "By pass are you sure prompt."
    def cancel(service=:current)
      task_definition = options[:task] || service # convention
      Cancel.new(service, options).run
    end

    desc "current SERVICE", "Switch the current service. Saves to .ufo/current"
    long_desc Help.text(:current)
    option :unset, type: :boolean, desc: "Unset current service to nothing. Removes .ufo/current"
    def current(service=nil)
      Current.new(service, options).run
    end

    desc "destroy SERVICE", "Destroy the ECS service."
    long_desc Help.text(:destroy)
    option :sure, type: :boolean, desc: "By pass are you sure prompt."
    def destroy(service=:current)
      task_definition = options[:task] || service # convention
      Destroy.new(service, options).bye
    end

    desc "info SERVICE", "Info about the ECS service."
    long_desc Help.text(:info)
    def info(service=:current)
      Info.new(service, options).run
    end

    desc "scale SERVICE COUNT", "Scale the ECS service."
    long_desc Help.text(:scale)
    def scale(service=:current, count)
      Scale.new(service, count, options).update
    end

    desc "completion *PARAMS", "Prints words for auto-completion."
    long_desc Help.text("completion")
    def completion(*params)
      Completer.new(CLI, *params).run
    end

    desc "completion_script", "Generates a script that can be eval to setup auto-completion.", hide: true
    long_desc Help.text("completion_script")
    def completion_script
      Completer::Script.generate
    end

    desc "upgrade3", "Upgrade from version 2 to 3."
    def upgrade3
      Upgrade3.new(options).run
    end

    desc "upgrade3_3_to_3_4", "Upgrade from version 3.3 to 3.4"
    def upgrade3_3_to_3_4
      Upgrade33_to_34.new(options).run
    end

    desc "version", "Prints version number of installed ufo."
    def version
      puts VERSION
    end

    no_tasks do
      def build_docker
        builder = Docker::Builder.new(options)
        builder.build
        builder.push
        builder
      end

      def cleanup(image_name)
        Docker::Cleaner.new(image_name, options).cleanup
        Ecr::Cleaner.new(image_name, options).cleanup
      end
    end
  end
end
