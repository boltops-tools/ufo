require 'yaml'

module Ufo
  class Setting
    extend Memoist
    autoload :Profile, "ufo/setting/profile"

    def initialize(check_ufo_project=true)
      @check_ufo_project = check_ufo_project
    end

    # data contains the settings.yml config.  The order or precedence for settings
    # is the project ufo/settings.yml and then the ~/.ufo/settings.yml.
    def data
      if @check_ufo_project && !File.exist?(project_settings_path)
        Ufo.check_ufo_project!
      end

      # project based settings files
      project = load_file(project_settings_path)

      user_file = "#{ENV['HOME']}/.ufo/settings.yml"
      user = File.exist?(user_file) ? YAML.load_file(user_file) : {}

      default_file = File.expand_path("../default/settings.yml", __FILE__)
      default = load_file(default_file)

      all_envs = default.deep_merge(user.deep_merge(project))
      all_envs = merge_base(all_envs)
      data = all_envs[ufo_env] || all_envs["base"] || {}
      data.deep_symbolize_keys
    end
    memoize :data

    # Resovles infinite problem since Ufo.env can be determined from UFO_ENV or settings.yml files.
    # When ufo is determined from settings it should not called Ufo.env since that in turn calls
    # Settings.new.data which can then cause an infinite loop.
    def ufo_env
      settings = YAML.load_file("#{Ufo.root}/.ufo/settings.yml")
      env = settings.find do |_env, section|
        section ||= {}
        ENV['AWS_PROFILE'] && ENV['AWS_PROFILE'] == section['aws_profile']
      end

      ufo_env = env.first if env
      ufo_env = ENV['UFO_ENV'] if ENV['UFO_ENV'] # highest precedence
      ufo_env || 'development'
    end

  private
    def load_file(path)
      return Hash.new({}) unless File.exist?(path)

      content = RenderMePretty.result(path)
      data = YAML.load(content)
      # If key is is accidentally set to nil it screws up the merge_base later.
      # So ensure that all keys with nil value are set to {}
      data.each do |env, _setting|
        data[env] ||= {}
      end
      data
    end

    # automatically add base settings to the rest of the environments
    def merge_base(all_envs)
      base = all_envs["base"] || {}
      all_envs.each do |env, settings|
        all_envs[env] = base.merge(settings) unless env == "base"
      end
      all_envs
    end

    def project_settings_path
      "#{Ufo.root}/.ufo/settings.yml"
    end
  end
end
