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

      if @check_ufo_project && !a_settings_file_exists?
        puts "ERROR: No settings file at #{project_settings_path}.  Are you sure you are in a project with ufo setup?"
        puts "Please create a settings file via: ufo init"
        exit 1
      end

      # project based settings files
      env = File.exist?(env_settings_path) ? YAML.load_file(env_settings_path) : {}
      base = File.exist?(base_settings_path) ? YAML.load_file(base_settings_path) : {}

      user_file = "#{ENV['HOME']}/.ufo/settings.yml"
      user = File.exist?(user_file) ? YAML.load_file(user_file) : {}

      default_file = File.expand_path("../default/settings.yml", __FILE__)
      default = YAML.load_file(default_file)

      @settings_yaml = default.merge(user.merge(base.merge(env)))
    end

  private
    # need either the base or env specific settings project file to exist
    def a_settings_file_exists?
      File.exist?(project_base_settings_path) || File.exist?(project_settings_path)
    end

    def project_base_settings_path
      "#{Ufo.root}/.ufo/settings/base.yml"
    end

    def project_settings_path
      "#{Ufo.root}/.ufo/settings/#{Ufo.env}.yml"
    end
  end
end
