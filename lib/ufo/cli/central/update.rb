class Ufo::CLI::Central
  class Update
    include Ufo::Utils::Logging
    include Ufo::Utils::Execute
    include Ufo::Utils::Sure

    def initialize(options={})
      @options = options
    end

    def run
      validate!
      action = File.exist?(".ufo") ? "update" : "create"
      sure?("Will #{action} the .ufo symlink") # IE: Will create the .ufo symlink
      logger.info "Updating .ufo with #{repo}"
      FileUtils.mkdir_p(tmp_area)
      pull
      symlink
      check_gitignore
    end

    def pull
      logger.debug "Within #{tmp_area}"
      Dir.chdir(tmp_area) do
        if File.exist?(repo_name)
          execute "cd #{repo_name} && git pull"
        else
          execute "git clone #{repo}"
        end
      end
    end

    # Always update the symlink in case use changes UFO_CENTRAL_REPO
    def symlink
      src = "#{tmp_area}/#{repo_name}"
      src += "/#{folder}" if folder

      FileUtils.mv(".ufo", ".ufo.bak") if File.exist?(".ufo") && File.directory?(".ufo")

      # FileUtils.ln_s(target, link, options)
      # ~/.ufo/central/repo -> .ufo
      FileUtils.ln_s(src, ".ufo", verbose: true)
      FileUtils.rm_rf(".ufo.bak")

      logger.info "The .ufo symlink has been updated"
    end

    def validate!
      return if repo
      logger.info "ERROR: Please set the env var: UFO_CENTRAL_REPO".color(:red)
      logger.info "The ufo central update command requires it."
      exit 1
    end

    def repo_name
      File.basename(repo)
    end

    def repo
      ENV['UFO_CENTRAL_REPO']
    end

    def folder
      ENV['UFO_CENTRAL_FOLDER']
    end

    def tmp_area
      "#{ENV['HOME']}/.ufo/central"
    end

    def check_gitignore
      ok = false
      if File.exist?('.gitignore')
        lines = IO.readlines('.gitignore')
        ok = lines.detect do |line|
          line =~ %r{/?.ufo/?$}
        end
      end
      return if ok
      logger.info "No .ufo found in your .gitignore file".color(:yellow)
      logger.info <<~EOL
        It's recommended to add .ufo to the .gitignore
        When using ufo in a central fashion
      EOL
    end
  end
end
