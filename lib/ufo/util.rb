module Ufo
  module Util
    def execute(command, local_options={})
      command = "cd #{@project_root} && #{command}"
      # local_options[:live] overrides the global @options[:noop]
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
  end
end
