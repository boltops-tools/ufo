class Ufo::CLI::Central
  class Update < Base
    def run
      validate!
      action = File.exist?(".ufo") ? "update" : "create"
      sure?("Will #{action} the .ufo symlink") # IE: Will create the .ufo symlink
      logger.info "Updating .ufo with #{central_repo}"
      FileUtils.mkdir_p(tmp_area)
      pull
      symlink
      check_gitignore
    end

    def pull
      logger.debug "Within #{tmp_area}"
      Dir.chdir(tmp_area) do
        if File.exist?(repo)
          execute "cd #{repo} && git pull"
        else
          execute "git clone #{central_repo}"
        end
      end
    end

    # Always update the symlink in case use changes UFO_CENTRAL_REPO
    def symlink
      src = "#{tmp_area}/#{repo}"
      src += "/#{central_folder}" if central_folder

      FileUtils.mv(".ufo", ".ufo.bak") if File.exist?(".ufo") && File.directory?(".ufo")

      # FileUtils.ln_s(target, link, options)
      # ~/.ufo/central/repo -> .ufo
      FileUtils.ln_sf(src, ".ufo", verbose: false) # force in case of existing broken symlink
      FileUtils.rm_rf(".ufo.bak")

      report_broken_symlink

      logger.info "The .ufo symlink has been updated"
      logger.info "Symlink: .ufo -> #{pretty_home(src)}"
    end

    def report_broken_symlink
      return unless File.symlink?('.ufo')

      message =<<~EOL.color(:red)
        ERROR: The .ufo symlink appears to pointing to a missing folder.
        Please double check that the folder exist in the repo/
      EOL
      begin
        target = File.readlink('.ufo')
        unless File.exist?(target)
          logger.error message
          logger.error "Symlink: .ufo -> #{target}"
          exit 1
        end
      rescue Errno::EEXIST
        logger.error message
        exit 1
      end
    end

    def validate!
      return if central_repo
      logger.info "ERROR: Please set the env var: UFO_CENTRAL_REPO".color(:red)
      logger.info "The ufo central update command requires it."
      exit 1
    end

    # Assume github.com:org/repo. May not work for private "ssh://host:repo" style repos
    # See: https://terraspace.cloud/docs/terrafile/sources/ssh/
    # Will consider PRs.
    #
    # org is used for path to ~/.ufo/central/org/repo
    #
    def org
      base = central_repo.split('/')[-2] # 1. git@github.com:org/repo 2. repo (for case of https://github.com/org/repo)
      base.gsub!(/.*:/,'') # git@github.com:org/repo => org/repo
      base
    end

    def repo
      File.basename(central_repo)
    end

    def central_repo
      ENV['UFO_CENTRAL_REPO']
    end

    def central_folder
      ENV['UFO_CENTRAL_FOLDER']
    end

    def tmp_area
      "#{ENV['HOME']}/.ufo/central/#{org}"
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
