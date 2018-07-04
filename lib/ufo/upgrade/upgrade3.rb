require 'fileutils'
require 'yaml'

class Ufo::Upgrade
  class Upgrade3
    def initialize(options)
      @options = options
    end

    def run
      if File.exist?("#{Ufo.root}/.ufo")
        puts "It looks like you already have a .ufo folder in your project. This is the new project structure so exiting without updating anything."
        return
      end

      if !File.exist?("#{Ufo.root}/ufo")
        puts "Could not find a ufo folder in your project. Maybe you want to run ufo init to initialize a new ufo project instead?"
        return
      end

      puts "Upgrading structure of your current project to the new ufo version 3 project structure"
      upgrade_settings("ufo/settings.yml")
      user_settings_path = "#{ENV['HOME']}/.ufo/settings.yml"
      if File.exist?(user_settings_path)
        upgrade_settings(user_settings_path)
      end

      upgrade_variables
      upgrade_gitignore

      mv("ufo", ".ufo")
      puts "Upgrade complete."
      new_env_info
    end

    def upgrade_gitignore
      lines = IO.readlines(".gitignore")
      lines.map! do |line|
        line.sub(/[\/]?ufo/, '.ufo')
      end
      lines << [".ufo/data\n"] # new ignore rule
      text = lines.join
      IO.write(".gitignore", text)
    end

    def upgrade_variables
      upgrade_variable_path("dev")
      upgrade_variable_path("stag")
      upgrade_variable_path("prod")
    end

    def upgrade_variable_path(old_ufo_env)
      old_path = "ufo/variables/#{old_ufo_env}.rb"
      return unless File.exist?(old_path)

      ufo_env = map_env(old_ufo_env)
      mv(old_path, "ufo/variables/#{ufo_env}.rb")
    end

    def upgrade_settings(path)
      data = YAML.load_file(path)
      return if data.key?("base") # already in new format

      new_structure = {}

      (data["aws_profile_ufo_env_map"] || {}).each do |aws_profile, ufo_env|
        ufo_env = map_env(ufo_env)
        new_structure[ufo_env] ||= {}
        new_structure[ufo_env]["aws_profiles"] ||= []
        new_structure[ufo_env]["aws_profiles"] << aws_profile
      end
      data.delete("aws_profile_ufo_env_map")

      (data["ufo_env_cluster_map"] || {}).each do |ufo_env, cluster|
        ufo_env = map_env(ufo_env)
        new_structure[ufo_env] ||= {}
        new_structure[ufo_env]["cluster"] = cluster
      end
      data.delete("ufo_env_cluster_map")

      new_structure["base"] = data
      text = YAML.dump(new_structure)
      IO.write(path, text)
      puts "Upgraded settings: #{path}"
      if path.include?(ENV['HOME'])
        puts "NOTE: Your ~/.ufo/settings.yml file was also upgraded to the new format. If you are using ufo in other projects those will have to be upgraded also."
      end
    end

    ENV_MAP = {
      "dev" => "development",
      "prod" => "production",
      "stag" => "staging",
    }
    def map_env(ufo_env)
      ENV_MAP[ufo_env] || ufo_env
    end

    def new_env_info
      puts <<-EOL.colorize(:yellow)
INFO: The UFO_ENV default environment is now development.
The short env names have been mapped over to their longer names.
Examples:

  prod => production
  dev => development

To adjust the default UFO_ENV, export it in your ~/.profile. Example:

export UFO_ENV=production # the default is now development, when not set

Refer to https://github.com/tongueroo/ufo/blob/master/CHANGELOG.md for other notable changes.
EOL
    end

    def mv(src, dest)
      puts "mv #{src} #{dest}"
      FileUtils.mv(src, dest)
    end
  end
end
