require 'pathname'

module Ufo
  module Core
    autoload :Check, 'ufo/core/check'
    include Check

    # Ensures that UFO_ENV is always set to a default value.
    # For Ufo::Env.setup! we do not need to check if we're in a ufo project
    # Because we could not be at first. For example when: ufo init is first called.
    # Other uses of Ufo::Setting assumes that we should be in a ufo project.
    @@env = nil
    def env
      return @@env if @@env

      setting = Ufo::Setting.new(check_ufo_project=false).data
      map = setting['aws_profile_ufo_env_map']

      if map
        ufo_env = map[ENV['AWS_PROFILE']] || map['default']
      end
      ufo_env ||= 'development' # defaults to development
      ufo_env = ENV['UFO_ENV'] if ENV['UFO_ENV'] # highest precedence

      @@env = ufo_env
    end

    def root
      path = ENV['UFO_ROOT'] || '.'
      Pathname.new(path)
    end
  end
end
