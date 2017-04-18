require 'thor'
require 'ufo/cli/help'

module Ufo
  class Docker < Thor
    desc "build", "builds docker image"
    long_desc CLI::Help.docker_build
    option :push, type: :boolean, default: false
    def build
      builder = DockerBuilder.new(options)
      builder.build
      builder.push if options[:push]
    end

    desc "base", "builds docker image from Dockerfile.base and update current Dockerfile"
    long_desc CLI::Help.docker_base
    option :push, type: :boolean, default: true
    def base
      builder = DockerBuilder.new(options.dup.merge(
        image_namespace: "base",
        dockerfile: "Dockerfile.base"
      ))
      builder.build
      builder.push if options[:push]
      builder.update_dockerfile
      DockerCleaner.new(builder.image_name, options.merge(tag_prefix: "base")).cleanup
      EcrCleaner.new(builder.image_name, options.merge(tag_prefix: "base")).cleanup
    end

    desc "image_name", "displays the full docker image with tag that will be generated"
    option :generate, type: :boolean, default: false, desc: "Generate a name without storing it"
    long_desc CLI::Help.docker_full_image_name
    def image_name
      full_image_name = DockerBuilder.new(options).full_image_name
      puts full_image_name
    end

    desc "cleanup IMAGE_NAME", "Cleans up old images.  Keeps a specified amount."
    option :keep, type: :numeric, default: 3
    option :tag_prefix, default: "ufo"
    long_desc CLI::Help.docker_cleanup
    def cleanup(image_name)
      DockerCleaner.new(image_name, options).cleanup
    end
  end

  class Tasks < Thor
    desc "build", "builds task definitions"
    long_desc CLI::Help.tasks_build
    option :pretty, type: :boolean, default: true, desc: "Pretty format the json for the task definitions"
    def build
      TasksBuilder.new(options).build
    end

    desc "register", "register all built task definitions in ufo/output"
    long_desc CLI::Help.tasks_register
    def register
      TasksRegister.register(:all, options)
    end
  end

  class CLI < Thor
    class_option :verbose, type: :boolean
    class_option :mute, type: :boolean
    class_option :noop, type: :boolean
    class_option :project_root, type: :string, default: '.'
    class_option :cluster, desc: "Cluster.  Overrides ufo/settings.yml."

    desc "docker ACTION", "docker related tasks"
    long_desc Help.docker
    subcommand "docker", Docker

    desc "tasks ACTION", "task definition related tasks"
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

    desc "ship [SERVICE]", "ships container to the ECS service"
    option :task, desc: "ECS task name, to override the task name convention."
    option :target_group, desc: "ELB Target Group ARN."
    option :elb, desc: "ELB Name associated with the target_group.  Assumes first "
    option :elb_prompt, type: :boolean, desc: "Enable ELB prompt", default: true
    option :docker, type: :boolean, desc: "Enable docker build and push", default: true
    option :wait, type: :boolean, desc: "Wait for deployment to complete", default: true
    option :pretty, type: :boolean, default: true, desc: "Pretty format the json for the task definitions"
    option :stop_old_tasks, type: :boolean, default: false, desc: "Stop old tasks after waiting for deploying to complete"
    option :ecr_keep, type: :numeric, desc: "ECR specific cleanup of old images.  Specifies how many images to keep.  Only runs if the images are ECR images. Defaults to keeping all the images."
    long_desc Help.ship
    def ship(service)
      builder = DockerBuilder.new(options) # outside if because it need docker.full_image_name
      if options[:docker]
        builder.build
        builder.push
      end

      # task definition and deploy logic are coupled in the Ship class.
      # Example: We need to know if the task defintion is a web service to see if we need to
      # add the elb target group.  The web service information is in the TasksBuilder
      # and the elb target group gets set in the Ship class.
      # So we always call these together.
      TasksBuilder.new(options).build
      task_definition = options[:task] || service # convention
      TasksRegister.register(task_definition, options)
      ship = Ship.new(service, task_definition, options)

      return if ENV['TEST'] # to allow me to quickly test most of the ship CLI portion only
      ship.deploy
      if options[:docker]
        DockerCleaner.new(builder.image_name, options).cleanup
        EcrCleaner.new(builder.image_name, options).cleanup
      end
      puts "Docker image shipped: #{builder.full_image_name.green}"
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
  end
end
