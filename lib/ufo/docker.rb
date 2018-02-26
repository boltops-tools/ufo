module Ufo
  class Docker < Command
    autoload :Builder, 'ufo/docker/builder'
    autoload :Pusher, 'ufo/docker/pusher'
    autoload :Dockerfile, 'ufo/docker/dockerfile'
    autoload :Cleaner, 'ufo/docker/cleaner'

    desc "build", "Build docker image."
    long_desc Help.text("docker:build")
    option :push, type: :boolean, default: false
    def build
      builder = Docker::Builder.new(options)
      builder.build
      push if options[:push]
    end

    desc "push IMAGE", "Push the docker image."
    long_desc Help.text("docker:push")
    option :push, type: :boolean, default: false
    def push(full_image_name=nil)
      # full_image_name of nil results in defaulting to the last built image by ufo docker build
      pusher = Docker::Pusher.new(full_image_name, options)
      pusher.push
    end

    desc "base", "Build docker image from `Dockerfile.base` and update current `Dockerfile`."
    long_desc Help.text("docker:base")
    option :push, type: :boolean, default: true
    def base
      builder = Docker::Builder.new(options.dup.merge(
        image_namespace: "base",
        dockerfile: "Dockerfile.base"
      ))
      builder.build
      builder.push if options[:push]
      builder.update_dockerfile
      Docker::Cleaner.new(builder.image_name, options.merge(tag_prefix: "base")).cleanup
      Ecr::Cleaner.new(builder.image_name, options.merge(tag_prefix: "base")).cleanup
    end

    desc "name", "Display the full docker image with tag that was last generated."
    option :generate, type: :boolean, default: false, desc: "Generate a name without storing it"
    long_desc Help.text("docker:name")
    def name
      full_image_name = Docker::Builder.new(options).full_image_name
      puts full_image_name
    end

    desc "clean IMAGE_NAME", "Clean up old images.  Keeps a specified amount."
    option :keep, type: :numeric, default: 3
    option :tag_prefix, default: "ufo"
    long_desc Help.text("docker:clean")
    def clean(image_name)
      Docker::Cleaner.new(image_name, options).cleanup
    end
  end
end
