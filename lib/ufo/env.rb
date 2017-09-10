class Ufo::Env
  def self.setup!(project_root='.')
    settings = Ufo::Settings.new(project_root).data
    map = settings['aws_profile_ufo_env_map']

    ufo_env = map[ENV['AWS_PROFILE']] || map['default'] || 'prod' # defaults to prod
    ufo_env = ENV['UFO_ENV'] if ENV['UFO_ENV'] # highest precedence

    Kernel.const_set(:UFO_ENV, ufo_env)
  end
end
