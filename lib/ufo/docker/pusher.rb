require 'active_support/core_ext/module/delegation'

class Ufo::Docker
  class Pusher
    include Ufo::Util

    delegate :full_image_name, to: :builder
    attr_reader :last_image_name
    def initialize(options)
      @options = options
      @last_image_name = options[:image] || full_image_name
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
      @builder ||= Builder.new(@options)
    end

    def update_auth_token
      return unless ecr_image?
      repo_domain = "https://#{image_name.split('/').first}"
      auth = Ufo::Ecr::Auth.new(repo_domain)
      auth.update
    end

    def ecr_image?
      full_image_name =~ /\.amazonaws\.com/
    end

    # full_image - does not include the tag
    def image_name
      setting.data["image"]
    end

    def setting
      @setting ||= Ufo::Setting.new(Ufo.root)
    end
  end
end
