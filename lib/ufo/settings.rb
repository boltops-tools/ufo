require 'yaml'

module Ufo
  class Settings
    def initialize(project_root='.')
      @project_root = project_root
    end

    # data contains the settings.yml config.  The order or precedence for settings
    # is the project ufo/settings.yml and then the ~/.ufo/settings.yml.
    def data
      return @data if @data

      if File.exist?(settings_path)
        @data = YAML.load_file(settings_path)
        @data = user_settings.merge(@data)
      else
        puts "ERROR: No settings file file at #{settings_path}"
        puts "Please create a settings file via: ufo init"
        exit 1
      end
    end

    def user_settings
      path = "#{ENV['HOME']}/.ufo/settings.yml"
      File.exist?(path) ? YAML.load_file(path) : {}
    end

    def settings_path
      "#{@project_root}/ufo/settings.yml"
    end
  end
end
