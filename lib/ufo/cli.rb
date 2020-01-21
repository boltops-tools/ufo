require 'thor'
require 'ufo/command'

module Ufo
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :mute, type: :boolean
    class_option :noop, type: :boolean
    class_option :cluster, desc: "Cluster.  Overrides .ufo/settings.yml."

    desc "network SUBCOMMAND", "network subcommands"
    long_desc Help.text(:network)
    subcommand "network", Network

    desc "docker SUBCOMMAND", "docker subcommands"
    long_desc Help.text(:docker)
    subcommand "docker", Docker

    desc "tasks SUBCOMMAND", "task definition subcommands"
    long_desc Help.text(:tasks)
    subcommand "tasks", Tasks

    desc "upgrade SUBCOMMAND", "upgrade subcommands"
    long_desc Help.text(:upgrade)
    subcommand "upgrade", Upgrade

    long_desc Help.text(:init)
    Init.cli_options.each do |args|
      option(*args)
    end
    register(Init, "init", "init", "Set up initial ufo files.")

    # common options to deploy. ship, and ships command
    ship_options = Proc.new do
      # All elb options remember their 'state'
      option :ecr_keep, type: :numeric, desc: "ECR specific cleanup of old images.  Specifies how many images to keep.  Only runs if the images are ECR images. Defaults keeps all images."
      option :elb, desc: "Decides to create elb, not create elb or use existing target group."
      option :elb_eip_ids, type: :array, desc: "EIP Allocation ids to use for network load balancer."
      option :elb_type, desc: "ELB type: application or network. Keep current deployed elb type when not specified."
      option :pretty, type: :boolean, default: true, desc: "Pretty format the json for the task definitions"
      option :scheduling_strategy, desc: "Scheduling strategy to use for the service. IE: replica, daemon"
      option :stop_old_tasks, type: :boolean, default: false, desc: "Stop old tasks as part of deployment to speed it up"
      option :task, desc: "ECS task name, to override the task name convention."
      option :wait, type: :boolean, desc: "Wait for deployment to complete", default: true
    end

    desc "deploy SERVICE", "Deploy task definition to ECS service without re-building the definition."
    long_desc Help.text(:deploy)
    ship_options.call
    option :register, type: :boolean, desc: "Register task definition", default: true
    option :build, type: :boolean, desc: "Build task definition", default: true
    def deploy(service=:current)
      service = service == :current ? Current.service! : service
      task_definition = options[:task] || service # convention
      Tasks::Builder.build(options) if options[:build]
      Tasks::Register.register(task_definition, options) if options[:register]
      ship = Ship.new(service, options.merge(task_definition: task_definition))
      ship.deploy
    end

    desc "ship SERVICE", "Builds and ships container image to the ECS service."
    long_desc Help.text(:ship)
    ship_options.call
    def ship(service=:current)
      service = service == :current ? Current.service! : service
      builder = build_docker

      task_definition = options[:task] || service # convention
      Tasks::Builder.ship(task_definition, options)
      ship = Ship.new(service, options.merge(task_definition: task_definition))
      ship.deploy

      cleanup(builder.image_name)
    end

    desc "rollback SERVICE VERSION", "Rolls back to older task definition."
    long_desc Help.text(:rollback)
    def rollback(service=:current, version)
      service = service == :current ? Current.service! : service
      rollback = Rollback.new(service, options.merge(version: version))
      rollback.deploy
    end

    desc "ships [LIST_OF_SERVICES]", "Builds and ships same container image to multiple ECS services."
    long_desc Help.text(:ships)
    ship_options.call
    option :wait, type: :boolean, desc: "Wait for deployment to complete", default: false
    def ships(*services)
      builder = build_docker

      if services.empty? && !Current.services&.empty?
        services = Current.services
      end
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
    option :task_only, type: :boolean, desc: "Skip docker and task register steps. Only run the task."
    option :wait, type: :boolean, aliases: 'w', desc: "Wait for task to finish.", default: false
    option :timeout, type: :numeric, aliases: 't', desc: "How long to wait for task to finish.", default: 600
    option :command, type: :array, aliases: 'c', desc: "Override the command used for the container"
    def task(task_definition)
      Docker::Builder.build(options) unless @options[:task_only]
      Tasks::Builder.ship(task_definition, options) unless @options[:task_only]
      Task.new(task_definition, options).run
    end

    desc "cancel SERVICE", "Cancel creation or update of the ECS service."
    long_desc Help.text(:cancel)
    option :sure, type: :boolean, desc: "By pass are you sure prompt."
    def cancel(service=:current)
      task_definition = options[:task] || service # convention
      Cancel.new(service, options).run
    end

    desc "current SERVICE", "Switch the current service. Saves to `.ufo/current`"
    long_desc Help.text(:current)
    option :rm, type: :boolean, desc: "Remove all current settings. Removes `.ufo/current`"
    option :service, desc: "Sets service as a current setting."
    option :services, type: :array, desc: "Sets services as a current setting. This is used for ufo ships."
    option :env_extra, desc: "Sets UFO_ENV_EXTRA as a current setting."
    def current
      Current.new(options).run
    end

    desc "destroy SERVICE", "Destroy the ECS service."
    long_desc Help.text(:destroy)
    option :sure, type: :boolean, desc: "By pass are you sure prompt."
    option :wait, type: :boolean, desc: "Wait for completion", default: true
    def destroy(service=:current)
      task_definition = options[:task] || service # convention
      Destroy.new(service, options).bye
    end

    desc "apps", "List apps."
    long_desc Help.text(:apps)
    option :clusters, type: :array, desc: "List of clusters"
    def apps
      Apps.new(options).list_all
    end

    desc "resources SERVICE", "The ECS service resources."
    long_desc Help.text(:resources)
    def resources(service=:current)
      Info.new(service, options).run
    end

    desc "scale SERVICE COUNT", "Scale the ECS service."
    long_desc Help.text(:scale)
    def scale(service=:current, count)
      Scale.new(service, count, options).update
    end

    desc "ps SERVICE", "Show process info on ECS service."
    long_desc Help.text(:ps)
    option :summary, type: :boolean, default: true, desc: "Display summary header info."
    option :extra, type: :boolean, default: false, desc: "Display extra debugging columns."
    option :status, default: "all", desc: "Status filter: all, pending, stopped, running."
    def ps(service=:current)
      Ps.new(service, options).run
    end

    desc "releases SERVICE", "Show possible 'releases' or task definitions for the service."
    long_desc Help.text(:releases)
    def releases(service=:current)
      Releases.new(service, options).list
    end

    desc "stop SERVICE", "Stop tasks from old deployments.  Can speed up deployments with network load balancer."
    long_desc Help.text(:stop)
    def stop(service=:current)
      Stop.new(service, options).run
    end

    desc "status SERVICE", "Status of ECS service.  Essentially, status of CloudFormation stack"
    long_desc Help.text(:status)
    def status(service=:current)
      Status.new(service, options).run
    end

    desc "logs", "Prints out logs"
    long_desc Help.text(:logs)
    option :follow, default: true, type: :boolean, desc: " Whether to continuously poll for new logs. To exit from this mode, use Control-C."
    option :since, desc: "From what time to begin displaying logs.  By default, logs will be displayed starting from 1 minutes in the past. The value provided can be an ISO 8601 timestamp or a relative time."
    option :format, default: "simple", desc: "The format to display the logs. IE: detailed or short.  With detailed, the log stream name is also shown."
    option :filter_pattern, desc: "The filter pattern to use. If not provided, all the events are matched"
    def logs(service=:current)
      Logs.new(service, options).run
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
