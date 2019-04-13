require 'fileutils'
require 'yaml'

class Ufo::Upgrade
  class Upgrade33to34
    def initialize(options)
      @options = options
    end

    def run
      if File.exist?("#{Ufo.root}/.ufo/params.yml")
        puts "It looks like you already have a .ufo/params.yml project. This is the new project structure so exiting without updating anything."
        return
      end

      create_params_yaml
      warn_about_removing_new_service_from_settings
    end

    def create_params_yaml
      src = File.expand_path("./upgrade/params.yml", File.dirname(__FILE__))
      dest = "#{Ufo.root}/.ufo/params.yml"
      FileUtils.cp(src, dest)
      puts "File .ufo/params.yml created.".color(:green)
      puts "Please check it out and adjust it to your needs."
    end

    def warn_about_removing_new_service_from_settings
      puts "WARN: The new_service option is not longer a part of the .ufo/settings.yml.  Please remove it.  It is now a part of the .ufo/params.yml file."
    end
  end
end

