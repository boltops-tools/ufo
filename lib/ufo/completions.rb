# Code Explanation.  This is mainly focused on the run method.
#
# There are 3 main branches of logic for completions:
#
#   1. top-level commands - when there are zero completed words
#   2. params completions - when a command has some required params
#   3. options completions - when we have finished auto-completing the top-level command and required params, the rest of the completion will be the command options
#
# Terms:
#
#   params - these are params in the command itself. Example: for the method `scale(service, count)` the params are `service, count`.
#   options - these are cli options flags.  Examples: --noop, --verbose
#
# When we are done processing method params, the completions will be only options. When detected params size greater than arity we are have finished
# auto-completing the parameters in the method declaration.  Example:
#
#   scale(service, count) = arity of 2
#
#   ufo scale service count [TAB] # there are 3 params includin the "scale" command
#
# So the completions will be something like:
#
#   --noop --verbose etc
#
# A note about artity values:
#
# We are using the arity of the command method to determine if we have finish auto-completing the params completions. When the ruby method has a splat param, it's arity will be negative.  Here are some example methods and their arities.
#
#    ship(service) = 1
#    scale(service, count) = 2
#    ships(*services) = -1
#    foo(example, *rest) = -2
#
# Fortunately, negative and positive arity values are processed the same way. So we take simply take the abs of the arity.
#
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
    autoload :Script, 'ufo/completions/script'

    def initialize(*params)
      log "params #{params.inspect}"
      @params = params
    end

    def run
      if @params.size == 0
        puts all_commands
        return
      end

      current_command = @params[0]
      arity = Ufo::CLI.instance_method(current_command).arity.abs
      log "@params.size > arity"
      log "#{@params.size} > #{arity}"
      if @params.size > arity
        puts options_completions(current_command)
      else
        puts params_completions(current_command)
      end

      log ""
    end

    def all_commands
      commands = CLI.all_commands.reject do |k,v|
        v.is_a?(Thor::HiddenCommand)
      end
      commands.keys
    end

    def options_completions(current_command)
      log "options_completions"
      used = ARGV.select { |a| a.include?('--') } # so we can remove used options
      method_options = CLI.all_commands[current_command].options.keys
      class_options = Ufo::CLI.class_options.keys
      all_options = method_options + class_options

      all_options.map! { |o| "--#{o.to_s.dasherize}" }
      filtered_options = all_options - used
      filtered_options
    end

    def params_completions(current_command)
      log "params_completions"
      method_params = Ufo::CLI.instance_method(current_command).parameters
      # Example:
      # >> Ufo::CLI.instance_method(:scale).parameters
      # => [[:req, :service], [:req, :count]]
      # >> Ufo::CLI.instance_method(:ships).parameters
      # => [[:rest, :services]]
      # >>
      method_params.map!(&:last)

      offset = @params.size - 1
      offset_params = method_params[offset..-1]
      log "offset #{offset}"
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
