require 'active_support/core_ext/hash'

module Ufo
  module Util
    # The default cluster normally defaults to the Ufo.env value.
    # But it can be overriden by ufo/settings.yml cluster
    #
    # More info: http://ufoships.com/docs/settings/
    def default_cluster
      settings["cluster"] || Ufo.env
    end

    # Keys are strings for simplicity.
    def settings
      @settings ||= Ufo.settings
    end

    # Naming it default_params because params is too commonly used in ufo.
    # Param keys must be symbols for the aws-sdk calls.
    def default_params
      @default_params ||= Param.new.data.deep_symbolize_keys
    end

    def execute(command, local_options={})
      if @options[:noop] && !local_options[:live]
        say "NOOP: #{command}"
        result = true # always success with no noop for specs
      else
        if local_options[:use_system]
          result = system(command)
        else
          result = `#{command}`
        end
      end
      result
    end

    # http://stackoverflow.com/questions/4175733/convert-duration-to-hoursminutesseconds-or-similar-in-rails-3-or-ruby
    def pretty_time(total_seconds)
      minutes = (total_seconds / 60) % 60
      seconds = total_seconds % 60
      if total_seconds < 60
        "#{seconds.to_i}s"
      else
        "#{minutes.to_i}m #{seconds.to_i}s"
      end
    end

    def display_params(options)
      puts YAML.dump(options.deep_stringify_keys)
    end
  end
end
