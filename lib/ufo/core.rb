require 'pathname'
require 'yaml'

module Ufo
  module Core
    extend Memoist

    def role
      ENV['UFO_ROLE'] || 'web'
    end

    def app
      ENV['UFO_APP'] || config.app
    end

    # v5: development is default
    # v6: dev is default
    def env
      ENV['UFO_ENV'] || 'dev'
    end
    memoize :env

    def extra
      extra = ENV['UFO_EXTRA'] if ENV['UFO_EXTRA'] # highest precedence
      return if extra&.empty?
      extra
    end
    memoize :extra

    def root
      path = ENV['UFO_ROOT'] || '.'
      Pathname.new(path)
    end

    def log_root
      "#{root}/log"
    end

    def configure(&block)
      Config.instance.configure(&block)
    end

    # Generally, use the Lono.config instead of Config.instance.config since it guarantees the load_project_config call
    cattr_accessor :config_loaded
    def config
      Config.instance.load_project_config
      @@config_loaded = true
      Config.instance.config
    end
    memoize :config

    # Allow different logger when running up all or rspec-lono
    cattr_writer :logger
    def logger
      if @@config_loaded
        @@logger = config.logger
      else
        # Hackery for case when .ufo/config.rb is not yet loaded. IE: a helper method like waf
        # gets called in the .ufo/config.rb itself and uses the logger.
        # This avoids an infinite loop
        @@logger ||= Logger.new(ENV['UFO_LOG_PATH'] || $stderr)
      end
    end
  end
end
