require 'yaml'

module Ufo
  class Setting
    def initialize(check_ufo_project=true)
      @check_ufo_project = check_ufo_project
    end

    # data contains the settings.yml config.  The order or precedence for settings
    # is the project ufo/settings.yml and then the ~/.ufo/settings.yml.
    def data
      return @data if @data

      if @check_ufo_project && !File.exist?(project_settings_path)
        puts "ERROR: No settings file at #{project_settings_path}.  Are you sure you are in a project with ufo setup?"
        puts "If you want to set up ufo for this prjoect, please create a settings file via: ufo init"
        exit 1
      end

      # project based settings files
      project = load_file(project_settings_path)

      user_file = "#{ENV['HOME']}/.ufo/settings.yml"
      user = File.exist?(user_file) ? YAML.load_file(user_file) : {}

      default_file = File.expand_path("../default/settings.yml", __FILE__)
      default = load_file(default_file)

      all_envs = default.deep_merge(user.deep_merge(project))
      all_envs = merge_base(all_envs)
      @@data = all_envs[Ufo.env] || all_envs["base"] || {}
    end

  private
    def load_file(path)
      return Hash.new({}) unless File.exist?(path)

      content = RenderMePretty.result(path)
      data = YAML.load(content)
      # If key is is accidentally set to nil it screws up the merge_base later.
      # So ensure that all keys with nil value are set to {}
      data.each do |ufo_env, _setting|
        data[ufo_env] ||= {}
      end
      data
    end

    # automatically add base settings to the rest of the environments
    def merge_base(all_envs)
      base = all_envs["base"]
      all_envs.each do |ufo_env, env_settings|
        all_envs[ufo_env] = base.merge(env_settings) unless ufo_env == "base"
      end
      all_envs
    end

    def project_settings_path
      "#{Ufo.root}/.ufo/settings.yml"
    end
  end
end
