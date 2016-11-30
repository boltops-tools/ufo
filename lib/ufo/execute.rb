module Ufo
  module Execute
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
  end
end
