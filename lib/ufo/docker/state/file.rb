class Ufo::Docker::State
  class File < Base
    def read
      current_data
    end

    def update
      data = current_data
      data["base_image"] = @base_image

      pretty_path = state_path.sub("#{Ufo.root}/", "")
      FileUtils.mkdir_p(::File.dirname(state_path))
      IO.write(state_path, YAML.dump(data))

      logger.info "The #{pretty_path} base_image has been updated with the latest base image:".color(:green)
      logger.info "    #{@base_image}".color(:green)
      reminder_message
    end

    def current_data
      ::File.exist?(state_path) ? YAML.load_file(state_path) : {}
    end

    def state_path
      "#{Ufo.root}/.ufo/state/#{Ufo.app}/#{Ufo.env}/data.yml"
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
