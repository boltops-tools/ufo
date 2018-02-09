class Ufo::Env
  def self.setup!(project_root='.')
    # Ensures that  UFO_ENV is always set to a default value.
    # For Ufo::Env.setup! we do not need to check if we're in a ufo project
    # Because we could not be at first. For example when: ufo init is first called.
    # Other uses of Ufo::Settings assumes that we should be in a ufo project.
    settings = Ufo::Settings.new(project_root, false).data
    map = settings['aws_profile_ufo_env_map']

    if map
      ufo_env = map[ENV['AWS_PROFILE']] || map['default']
    end
    ufo_env ||= 'development' # defaults to development
    ufo_env = ENV['UFO_ENV'] if ENV['UFO_ENV'] # highest precedence

    Kernel.const_set(:UFO_ENV, ufo_env)
  end
end
