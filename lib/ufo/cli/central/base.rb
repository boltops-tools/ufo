class Ufo::CLI::Central
  class Base
    include Ufo::Utils::Pretty
    include Ufo::Utils::Sure

    def initialize(options={})
      @options = options
    end

    # Do not use logger.info for ufo central commands as .ufo may not be yet setup
    # We do not want any config calls to trigger a loading of the .ufo/config.rb etc
    # Otherwise helper methods like ecr_repo may be called and not work yet
    def log(msg)
      puts msg
    end

    # Central has own version of execute because it doesnt have access to logger
    def execute(command)
      log "=> #{command}"
      system command
    end
  end
end
