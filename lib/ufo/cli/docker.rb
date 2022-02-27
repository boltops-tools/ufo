class Ufo::CLI
  class Docker < Ufo::Command
    desc "build", "Build docker image."
    long_desc Help.text("docker/build")
    option :push, type: :boolean, default: false
    def build
      builder = Ufo::Docker::Builder.new(options)
      builder.build
      push if options[:push]
    end

    desc "compile", "Compile Dockerfile.erb"
    long_desc Help.text("docker/compile")
    def compile
      builder = Ufo::Docker::Builder.new(options)
      builder.compile
    end

    desc "push IMAGE", "Push the docker image."
    long_desc Help.text("docker/push")
    option :push, type: :boolean, default: false
    def push(docker_image=nil)
      # docker_image of nil results in defaulting to the last built image by ufo docker build
      pusher = Ufo::Docker::Pusher.new(docker_image, options)
      pusher.push
    end

    desc "base", "Build docker image from `Dockerfile.base` and update current `Dockerfile`."
    long_desc Help.text("docker/base")
    option :push, type: :boolean, default: true
    def base
      builder = Ufo::Docker::Builder.new(options.dup.merge(
        image_namespace: "base",
        dockerfile: "Dockerfile.base"
      ))
      builder.build
      builder.push if options[:push]
      builder.update_dockerfile
      Ufo::Docker::Cleaner.new(builder.image_name, options.merge(tag_prefix: "base")).cleanup
      Ufo::Ecr::Cleaner.new(builder.image_name, options.merge(tag_prefix: "base")).cleanup
    end

    desc "name", "Display the full docker image with tag that was last generated."
    option :generate, type: :boolean, default: false, desc: "Generate a name without storing it"
    long_desc Help.text("docker/name")
    def name
      docker_image = Ufo::Docker::Builder.new(options).docker_image
      puts docker_image
    end

    desc "clean IMAGE_NAME", "Clean up old images.  Keeps a specified amount."
    option :keep, type: :numeric, default: 3
    option :tag_prefix, default: "ufo"
    long_desc Help.text("docker/clean")
    def clean(image_name)
      Docker::Cleaner.new(image_name, options).cleanup
    end
  end
end
