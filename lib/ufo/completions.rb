# To test:
#
#   ufo completions
#   ufo completions scale
#   ufo completions scale service
#   ufo completions scale service count
#
#   ufo completions
#   ufo completions ship
#
#   ufo completions
#   ufo completions ships
#   ufo completions ships services
#
module Ufo
  class Completions
    def initialize(*params)
      @params = params
    end

    def run
      if @params.size == 0
        puts all_commands
        return
      end

      current_command = @params[0]
      arity = Ufo::CLI.instance_method(current_command).arity.abs
      # artity value examples:
      #
      #  ship(service) = 1
      #  scale(service, count) = 2
      #  ships(*services) = -1
      #  foo(example, *rest) = -2
      #
      # Negative and positive arity values are handled the same way;
      # thats why we take the abs of the arity.

      if @params.size > arity
        # When arity is positive and greater than arity we are have finished
        # auto-completing the parameters in the method declaration.  Example:
        #
        #   scale(service, count) = arity of 2
        #
        #   ufo scale service count [TAB]
        #
        # Will return --noop --verbose etc
        #
        # So we are done with method params, the completions should be
        # all flag options now.
        puts options_completions(current_command)
      else
        puts params_completions(current_command)
      end
    end

    def all_commands
      commands = CLI.all_commands.reject do |k,v|
        v.is_a?(Thor::HiddenCommand)
      end
      commands.keys
    end

    def options_completions(current_command)
      used = ARGV.select {|a| a.include?('--')} # to remove used options
      method_options = CLI.all_commands[current_command].options.keys
      class_options = Ufo::CLI.class_options.keys
      all_options = method_options + class_options

      all_options.map! { |o| "--#{o.to_s.dasherize}" }
      filtered_options = all_options - used
      filtered_options
    end

    def params_completions(current_command)
      log "params equal or less than arity. processing method params"
      method_params = Ufo::CLI.instance_method(current_command).parameters
      # Example:
      # >> Ufo::CLI.instance_method(:scale).parameters
      # => [[:req, :service], [:req, :count]]
      # >> Ufo::CLI.instance_method(:ships).parameters
      # => [[:rest, :services]]
      # >>
      method_params.map!(&:last)

      # log "method_params #{method_params.inspect}"
      # log "@params.size #{@params.size}"
      offset = @params.size - 1
      # log "offset #{offset}"
      offset_params = method_params[offset..-1]
      log "offset_params #{offset_params.inspect}"
      method_params[offset..-1].first
    end

    def log(msg)
      File.open("/tmp/ufo.log", "a") do |file|
        file.puts(msg)
      end
    end
  end
end
