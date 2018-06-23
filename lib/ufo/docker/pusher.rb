require 'active_support/core_ext/module/delegation'

class Ufo::Docker
  class Pusher
    include Ufo::Util

    delegate :full_image_name, to: :builder
    attr_reader :last_image_name
    def initialize(image, options)
      @options = options
      # full_image_name ultimately uses @options, so @last_image_name assignment
      # line must be defined after setting @options.
      @last_image_name = image || full_image_name
    end

    def push
      update_auth_token
      start_time = Time.now
      message = "Pushed #{last_image_name} docker image."
      if @options[:noop]
        message = "NOOP #{message}"
      else
        command = "docker push #{last_image_name}"
        puts "=> #{command}".colorize(:green)
        success = execute(command, use_system: true)
        unless success
          puts "ERROR: The docker image fail to push.".colorize(:red)
          exit 1
        end
      end
      took = Time.now - start_time
      message << " Took #{pretty_time(took)}.".green
      puts message unless @options[:mute]
    end

    def builder
      @builder ||= Builder.new(@options.merge(image: last_image_name))
    end

    def update_auth_token
      auth = Ufo::Ecr::Auth.new(last_image_name)
      # wont update auth token unless the image being pushed in the ECR image format
      auth.update
    end

    # full_image - does not include the tag
    def image_name
      settings[:image]
    end
  end
end
