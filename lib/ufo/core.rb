require 'pathname'

module Ufo
  module Core
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

    def validate_in_project!
      unless File.exist?("#{root}/ufo")
        puts "Could not find a ufo folder in the current directory.  It does not look like you are running this command within a project that has been setup with ufo.  Please confirm that you are in a project and try again.  If you need to set up ufo on the project, check out ufo init -h".colorize(:red)
        exit
      end
    end
  end
end
