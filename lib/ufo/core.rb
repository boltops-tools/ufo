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
    def config
      Config.instance.load_project_config
      Config.instance.config
    end
    memoize :config

    # allow different logger when running up all or rspec-lono
    cattr_writer :logger
    def logger
      @@logger ||= config.logger
    end
  end
end
