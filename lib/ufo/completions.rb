module Ufo
  class Completions
    def initialize(*params)
      # ["scale", ""] => ["scale"]
      @params = params.reject(&:empty?)
    end

    def run
      return if @params.size == 0

      current_command = @params[0]

      # TODO: arity -1 ships command, and -2 for foo(a, *rest)

      # log "current_command: #{current_command}"
      arity = Ufo::CLI.instance_method(current_command).arity
      log "arity #{arity.inspect}"
      # artity values:
      #  ships(*services) = -1
      #  ship(service) = 1
      #  scale(service, count) = 2
      #  foo(example, *rest) = -2

      if @params.size > arity
        # Done with any method params, the completions will be flag options now.
        #
        # When arity is positive and greater than arity we are have auto-completed
        # the command parameters.  Example:
        #
        #   scale(service, count) = 2
        #
        # ufo scale service count
        #

        log "here1 params greater than arity"

        used = ARGV.select {|a| a.include?('--')}

        method_options = CLI.all_commands[current_command].options.keys
        class_options = Ufo::CLI.class_options.keys
        all_options = method_options + class_options


        all_options.map! { |o| "--#{o.to_s.dasherize}" }
        filtered_options = all_options - used
        puts filtered_options
      else

        log "here2 processing method params: #{@params.inspect} @params.size: #{@params.size} arity: #{arity}"
        method_params = Ufo::CLI.instance_method(current_command).parameters.map(&:last)
        # log "method_params #{method_params.inspect}"
        # log "@params.size #{@params.size}"
        offset = @params.size - 1
        # log "offset #{offset}"
        offset_params = method_params[offset..-1]
        log "offset_params #{offset_params.inspect}"
        puts method_params[offset..-1].first
      end
    end

    def log(msg)
      File.open("/tmp/ufo.log", "a") do |file|
        file.puts(msg)
      end
    end
  end
end
