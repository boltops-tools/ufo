require 'pathname'
require 'yaml'

module Ufo
  module Core
    autoload :Check, 'ufo/core/check'
    include Check

    def root
      path = ENV['UFO_ROOT'] || '.'
      Pathname.new(path)
    end

    @@env = nil
    def env
      return @@env if @@env
      ufo_env = env_from_profile(ENV['AWS_PROFILE']) || 'development'
      ufo_env = ENV['UFO_ENV'] if ENV['UFO_ENV'] # highest precedence
      @@env = ufo_env
    end

    private
    # Do not use the Setting class to load the profile because it can cause an
    # infinite loop then if we decide to use Ufo.env from within settings class.
    def env_from_profile(aws_profile)
      data = YAML.load_file("#{Ufo.root}/.ufo/settings.yml")
      env = data.find do |_env, setting|
        profiles = setting['profiles']
        profiles && profiles.include?(aws_profile)
      end
      env.first if env
    end
  end
end
