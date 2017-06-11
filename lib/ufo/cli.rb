require 'thor'
require 'ufo/command'
require 'ufo/cli/help'

module Ufo
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :mute, type: :boolean
    class_option :noop, type: :boolean
    class_option :project_root, type: :string, default: '.'
    class_option :cluster, desc: "Cluster.  Overrides ufo/settings.yml."

    desc "docker [ACTION]", "docker related tasks"
    long_desc Help.docker
    subcommand "docker", Docker

    desc "tasks [ACTION]", "task definition related tasks"
    long_desc Help.tasks
    subcommand "tasks", Tasks

    desc "init", "setup initial ufo files"
    option :cluster, type: :string, required: true, desc: "ECS cluster name. Example: default"
    option :image, type: :string, required: true, desc: "Docker image name without the tag. Example: tongueroo/hi"
    option :app, type: :string, required: true, desc: "App name. Preferably one word. Used in the generated ufo/task_definitions.rb."
    long_desc Help.init
    def init
      Init.new(options).setup
    end

    # common options to ship and ships command
    ship_options = Proc.new do
      option :task, desc: "ECS task name, to override the task name convention."
      option :target_group, desc: "ELB Target Group ARN."
      option :elb, desc: "ELB Name associated with the target_group.  Assumes first "
      option :elb_prompt, type: :boolean, desc: "Enable ELB prompt", default: true
      option :docker, type: :boolean, desc: "Enable docker build and push", default: true
      option :wait, type: :boolean, desc: "Wait for deployment to complete", default: false
      option :pretty, type: :boolean, default: true, desc: "Pretty format the json for the task definitions"
      option :stop_old_tasks, type: :boolean, default: false, desc: "Stop old tasks after waiting for deploying to complete"
      option :ecr_keep, type: :numeric, desc: "ECR specific cleanup of old images.  Specifies how many images to keep.  Only runs if the images are ECR images. Defaults to keeping all the images."
    end

    desc "ship [SERVICE]", "builds and ships container image to the ECS service"
    long_desc Help.ship
    ship_options.call
    def ship(service)
      builder = build_docker(options)
      task_definition = options[:task] || service # convention
      register_task(task_definition, options)
      return if ENV['TEST'] # allows quick testing of the ship CLI portion only

      ship = Ship.new(service, task_definition, options)
      ship.deploy
      if options[:docker]
        Docker::Cleaner.new(builder.image_name, options).cleanup
        Ecr::Cleaner.new(builder.image_name, options).cleanup
      end
      puts "Docker image shipped: #{builder.full_image_name.green}"
    end

    desc "ships [LIST-OF-SERVICES]", "builds and ships same container image to multiple ECS services"
    long_desc Help.ships
    ship_options.call
    def ships(*services)
      puts "services #{services.inspect}"
    end

    desc "task [TASK_DEFINITION]", "runs a one time task"
    long_desc Help.task
    option :docker, type: :boolean, desc: "Enable docker build and push", default: true
    option :command, type: :array, desc: "Override the command used for the container"
    def task(task_definition)
      build_docker(options)
      register_task(task_definition, options)
      Task.new(task_definition, options).run
    end

    desc "destroy [SERVICE]", "destroys the ECS service"
    long_desc Help.destroy
    option :force, type: :boolean, desc: "By pass are you sure prompt."
    def destroy(service)
      task_definition = options[:task] || service # convention
      Destroy.new(service, options).bye
    end

    desc "scale [SERVICE] [COUNT]", "scale the ECS service"
    long_desc Help.scale
    def scale(service, count)
      Scale.new(service, count, options).update
    end

    desc "version", "Prints version number of installed ufo"
    def version
      puts Ufo::VERSION
    end

    no_tasks do
      def build_docker(options)
        builder = Docker::Builder.new(options) # outside if because it need docker.full_image_name
        if options[:docker]
          builder.build
          builder.push
        end
        builder
      end

      def register_task(task_definition, options)
        # task definition and deploy logic are coupled in the Ship class.
        # Example: We need to know if the task defintion is a web service to see if we need to
        # add the elb target group.  The web service information is in the Tasks::Builder
        # and the elb target group gets set in the Ship class.
        # So we always call these together.
        Tasks::Builder.new(options).build
        Tasks::Register.register(task_definition, options)
      end
    end
  end
end
