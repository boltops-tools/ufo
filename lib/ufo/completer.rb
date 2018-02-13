# Code Explanation.  This is mainly focused on the run method.
#
# There are 3 main branches of logic for completion:
#
#   1. top-level commands - when there are zero completed words
#   2. params completion - when a command has some required params
#   3. options completion - when we have finished auto-completing the top-level command and required params, the rest of the completion words will be options
#
# Terms:
#
#   params - these are params in the command itself. Example: for the method `scale(service, count)` the params would be `service, count`.
#   options - these are cli options flags.  Examples: --noop, --verbose
#
# When we are done processing method params, the completion will be only options. When the detected params size is greater than the arity we are have finished auto-completing the parameters in the method declaration.  For example, say you had a method for a CLI command with the following form:
#
#   scale(service, count) = arity of 2
#
#   ufo scale service count [TAB] # there are 3 params including the "scale" command
#
# So the completion will be something like:
#
#   --noop --verbose etc
#
# A note about artity values:
#
# We are using the arity of the command method to determine if we have finish auto-completing the params completion. When the ruby method has a splat param, it's arity will be negative.  Here are some example methods and their arities.
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
#   ufo completion
#   ufo completion hello
#   ufo completion hello name
#   ufo completion hello name --
#   ufo completion hello name --noop
#
#   ufo completion
#   ufo completion sub:goodbye
#   ufo completion sub:goodbye name
#
# Note when testing, the first top-level word must be an exact match
#
#   ufo completion hello # works fine
#   ufo completion he # incomplete, this will just break
#
# The completion assumes that the top-level word that is being passed in
# from completor/scripts.sh will always match exactly.  This must be the
# case.  For parameters, the word does not have to match exactly.
#
module Ufo
  class Completer
    autoload :Script, 'ufo/completer/script'

    def initialize(command_class, *params)
      @params = params
      @current_command = @params[0]
      log "@current_command #{@current_command.inspect}"
      @command_class = command_class # CLI initiall
    end

    def run
      if subcommand?(@current_command)
        subcommand_class = @command_class.subcommand_classes[@current_command]
        @params.shift # destructive
        Completer.new(subcommand_class, *@params).run # recursively use subcommand
        log "done1\n\n"
        return
      end

      # full command has been found!
      log "@current_command2 #{@current_command.inspect}"
      unless found?(@current_command)
        log "all commands for #{@current_command.inspect}"
        puts all_commands
        log "done2\n"
        return
      end

      # will only get to here if command aws found (above)
      log "@command_class #{@command_class}"
      log "@command_class.superclass #{@command_class.superclass}"
      arity = @command_class.instance_method(@current_command).arity.abs
      log "@params.size <= arity"
      log "#{@params.size} <= #{arity}"
      if @params.size <= arity
        log "params_completion"
        puts params_completion
      else
        log "options_completion"
        puts options_completion
      end
      log "done3\n\n"
    end

    def subcommand?(command)
      @command_class.subcommands.include?(command)
    end

    def found?(command)
      public_methods = @command_class.public_instance_methods(false)
      log "@command_class #{@command_class.inspect}"
      log "public_methods #{public_methods.inspect}"
      command && public_methods.include?(command.to_sym)
    end

    # all top-level commands
    def all_commands
      commands = @command_class.all_commands.reject do |k,v|
        v.is_a?(Thor::HiddenCommand)
      end
      commands.keys
    end

    def params_completion
      method_params = @command_class.instance_method(@current_command).parameters
      # Example:
      # >> Sub.instance_method(:goodbye).parameters
      # => [[:req, :name]]
      # >>
      method_params.map!(&:last)

      offset = @params.size - 1
      offset_params = method_params[offset..-1]
      method_params[offset..-1].first
    end

    def options_completion
      used = ARGV.select { |a| a.include?('--') } # so we can remove used options

      method_options = @command_class.all_commands[@current_command].options.keys
      class_options = @command_class.class_options.keys

      all_options = method_options + class_options + ['help']

      all_options.map! { |o| "--#{o.to_s.gsub('_','-')}" }
      filtered_options = all_options - used
      filtered_options.uniq
    end

    # Useful for debugging. Using puts messes up completion.
    def log(msg)
      File.open("/tmp/complete.log", "a") do |file|
        file.puts(msg)
      end
    end
  end
end
