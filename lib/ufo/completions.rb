module Ufo
  class Completions
    def initialize(*params)
      @params = params
    end

    def run
      return if @params.size == 0

      current_command = @params[0]

      # TODO: arity -1 ships command, and -2 for foo(a, *rest)

      # puts "current_command: #{current_command}"
      arity = Ufo::CLI.instance_method(current_command).arity
      if @params.size > arity
        # puts "here1"

        used = ARGV.select {|a| a.include?('--')}

        method_options = CLI.all_commands[current_command].options.keys
        class_options = Ufo::CLI.class_options.keys
        all_options = method_options + class_options


        all_options.map! { |o| "--#{o.to_s.dasherize}" }
        filtered_options = all_options - used
        puts filtered_options
      else
        # puts "here2"
        method_params = Ufo::CLI.instance_method(current_command).parameters.map(&:last)
        # puts "method_params #{method_params.inspect}"
        # puts "@params.size #{@params.size}"
        offset = @params.size - 1
        # puts "offset #{offset}"
        puts method_params[offset..-1].first.upcase
      end
    end
  end
end
