module Ufo::Utils
  module Execute
    def execute(command, options={})
      log = options[:log]
      if log
        command += " >> #{log}"
        logger.info "=> #{command}"
        FileUtils.mkdir_p(File.dirname(log))
        File.open(log, 'a') { |f| f.puts "=> #{command}" }
        out = `#{command}`
        success = $?.success?
        unless success
          logger.error out
          exit 1
        end
        out
      else
        logger.info "=> #{command}"
        system(command)
      end
    end

    # TODO: remove these other metohds
    # Custom user params from .ufo/params.yml
    # Param keys are symbols for the aws-sdk calls.
    def user_params
      @user_params ||= Param.new.data
    end
  end
end
