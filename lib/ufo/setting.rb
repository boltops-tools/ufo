require 'yaml'

module Ufo
  class Setting
    def initialize(check_ufo_project=true)
      @check_ufo_project = check_ufo_project
    end

    # data contains the settings.yml config.  The order or precedence for settings
    # is the project ufo/settings.yml and then the ~/.ufo/settings.yml.
    def data
      return @settings_yaml if @settings_yaml

      if @check_ufo_project && !File.exist?(project_settings_path)
        puts "ERROR: No settings file at #{project_settings_path}.  Are you sure you are in a project with ufo setup?"
        puts "Please create a settings file via: ufo init"
        exit 1
      end

      # project based settings files
      project = load_file(project_settings_path)

      user_file = "#{ENV['HOME']}/.ufo/settings.yml"
      user = File.exist?(user_file) ? YAML.load_file(user_file) : {}

      default_file = File.expand_path("../default/settings.yml", __FILE__)
      default = YAML.load_file(default_file)

      @settings_yaml = default.deep_merge(user.deep_merge(project))[Ufo.env]
    end

  private
    def load_file(path)
      content = RenderMePretty.result(path)
      data = File.exist?(path) ? YAML.load(content) : {}
      # automatically add base settings to the rest of the environments
      data.each do |env, _setting|
        base = data["base"] || {}
        data[env] = base.merge(data[env]) unless env == "base"
      end
      data
    end

    def project_settings_path
      "#{Ufo.root}/.ufo/settings.yml"
    end
  end
end
