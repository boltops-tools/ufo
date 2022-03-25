module Ufo::Docker
  class Pusher
    include Concerns
    include Ufo::Hooks::Concern

    delegate :docker_image, to: :builder
    attr_reader :last_image_name
    def initialize(image, options)
      @options = options
      # docker_image ultimately uses @options, so @last_image_name assignment
      # line must be defined after setting @options.
      @last_image_name = image || docker_image
    end

    def push
      update_auth_token
      start_time = Time.now
      logger.info "Pushing Docker Image"
      command = "docker push #{last_image_name}"
      log = ".ufo/log/docker.log" if @options[:quiet]
      success = nil
      run_hooks(name: "push", file: "docker.rb") do
        success = execute(command, log: log)
      end
      unless success
        logger.info "ERROR: The docker image fail to push.".color(:red)
        exit 1
      end
      took = Time.now - start_time
      logger.info "Took #{pretty_time(took)}"
    end

    def builder
      @builder ||= Builder.new(@options.merge(image: last_image_name))
    end

    def update_auth_token
      auth = Ufo::Ecr::Auth.new(last_image_name)
      # wont update auth token unless the image being pushed in the ECR image format
      auth.update
    end
  end
end
