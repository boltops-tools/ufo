require 'fileutils'
require 'yaml'

module Ufo
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
      mv("ufo", ".ufo")
      puts "Upgrade complete."
    end

    def upgrade_settings(path)
      data = YAML.load_file(path)
      return if data.key?("base") # already in new format

      new_structure = {}

      (data["aws_profile_ufo_env_map"] || {}).each do |aws_profile, ufo_env|
        new_structure[ufo_env] ||= {}
        new_structure[ufo_env]["aws_profiles"] ||= []
        new_structure[ufo_env]["aws_profiles"] << aws_profile
      end
      data.delete("aws_profile_ufo_env_map")

      (data["ufo_env_cluster_map"] || {}).each do |ufo_env, cluster|
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

    def mv(src, dest)
      puts "mv #{src} #{dest}"
      FileUtils.mv(src, dest)
    end
  end
end
