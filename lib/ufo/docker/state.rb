module Ufo::Docker
  class State
    include Ufo::Utils::Logging
    include Ufo::Utils::Pretty

    def initialize(docker_image, options={})
      @docker_image, @options = docker_image, options
    end

    def update
      data = current_data
      data[Ufo.env] ||= {}
      data[Ufo.env]["base_image"] = @docker_image
      pretty_path = state_path.sub("#{Ufo.root}/", "")
      FileUtils.mkdir_p(File.dirname(state_path))
      IO.write(state_path, YAML.dump(data))
      logger.info "The #{pretty_path} base_image has been updated with the latest base image:".color(:green)
      logger.info "  #{@docker_image}".color(:green)
      reminder_message
    end

    def current_data
      File.exist?(state_path) ? YAML.load_file(state_path) : {}
    end

    def state_path
      path = "#{Ufo.root}/.ufo/state"
      if ENV['UFO_APP'] # env var activates app path
        path = "#{Ufo.root}/.ufo/state/#{Ufo.app}"
      end
      "#{path}/data.yml"
    end

    def reminder_message
      return unless Ufo.config.state.reminder
      repo = ENV['UFO_CENTRAL_REPO']
      return unless repo
      logger.info "It looks like you're using a central deployer pattern".color(:yellow)
      logger.info <<~EOL
        Remember to commit the state file:

            state file: #{pretty_path(state_path)}
            repo:       #{repo}

      EOL

      unless ENV['UFO_APP']
        logger.info "WARN: It also doesnt look like UFO_ENV is set".color(:yellow)
        logger.info "UFO_ENV should be set when you're using ufo in a central manner"
      end

      logger.info <<~EOL
        You can disable these reminder messages with:

        .ufo/config.rb

            Ufo.configure do |config|
              config.state.reminder = false
            end
      EOL
    end
  end
end
