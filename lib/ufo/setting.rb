require 'yaml'

module Ufo
  class Setting
    def initialize(project_root='.', check_ufo_project=true)
      @project_root = project_root
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

      project = File.exist?(project_settings_path) ?
                  YAML.load_file(project_settings_path) :
                  {}

      user_file = "#{ENV['HOME']}/.ufo/settings.yml"
      user = File.exist?(user_file) ? YAML.load_file(user_file) : {}

      default_file = File.expand_path("../default/settings.yml", __FILE__)
      default = YAML.load_file(default_file)

      @settings_yaml = default.merge(user.merge(project))
    end

  private
    def project_settings_path
      "#{@project_root}/ufo/settings.yml"
    end
  end
end
