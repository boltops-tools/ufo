require 'fileutils'
require 'yaml'

class Ufo::Upgrade
  class Upgrade4 < Ufo::Sequence
    Ufo::Upgrade.options.each { |o| class_option(*o) }

    # def already_ufo4_check
    #   if File.exist?("#{Ufo.root}/.ufo/settings/network/default.yml")
    #     puts "It looks like you already have a .ufo/network/default.yml file in your project. The current folder already contains the new project structure for ufo version 4. Exiting without updating anything."
    #     exit
    #   end

    #   if !File.exist?("#{Ufo.root}/.ufo")
    #     puts "Could not find a ufo folder in your project at all. Maybe you want to run ufo init to initialize a new ufo project instead?"
    #     exit
    #   end
    # end

    def upgrade
      puts "Upgrading structure of your current project to the new ufo version 4 project structure"
      upsert_dockerignore
      upsert_gitignore
      update_params_yaml
      update_settings
      new_files
    end

    def final_message
      puts "Upgrade complete."
      new_env_info
    end

  private
    def new_files
      template(".ufo/settings/network/default.yml")
      template(".ufo/version")
    end

    # add network_profile: default line
    def update_settings
      lines = IO.readlines("#{Ufo.root}/.ufo/settings.yml")
      new_lines = []

      lines.each do |line|
        new_lines << line
        if line.include?("base:")
          new_lines << "  network_profile: default # .ufo/settings/network/default.yml file\n"
        end
      end
      text = new_lines.join('')
      create_file(".ufo/settings.yml", text)
    end

    # remove the create_service and update_service sections
    def update_params_yaml
      lines = IO.readlines("#{Ufo.root}/.ufo/params.yml")
      new_lines = []

      remove = false
      lines.each do |line|
        remove = false if method_line?(line) # reset remove whenever meth line occurs
        remove ||= remove?(line)
        unless remove
          new_lines << line
        end
      end
      text = new_lines.join('')
      create_file(".ufo/params.yml", text)
    end

    def remove?(line)
      line.include?("create_service:") || line.include?("update_service:")
    end

    def method_line?(line)
      line =~ /^\w+:/
    end

    def upsert_dockerignore
      text = ".ufo\n"
      if File.exist?(".dockerignore")
        append_to_file ".dockerignore", text
      else
        create_file ".dockerignore", text
      end
    end

    def upsert_gitignore
      text =<<-EOL
.ufo/current
.ufo/data
.ufo/output
EOL
      if File.exist?(".gitignore")
        append_to_file ".gitignore", text
      else
        create_file ".gitignore", text
      end
    end

    def new_env_info
      puts <<-EOL.colorize(:yellow)
Congratulations, your project has been upgraded to ufo version 4. A major change in ufo from version 3 to 4 is that the ECS service is now created and managed by CloudFormation. So when you deploy your service with ufo version 4 for the first time it will create a new ecs additional ECS service.

    ufo ship SERVICE

After you see the additional ECS service, test it out and switch dns over to it when you're confident. Then it you can destroy the old ECS service with the ECS console. More details of the upgrade process is here https://ufoships.com/docs/upgrade4/

Also, in ufo version 4 there's a handy way to shorten the ufo commands with the ufo current command.  Example:

    ufo current --service my-service
    ufo ship my-service
    ufo ship # same as ufo ship my-service

Refer to https://github.com/tongueroo/ufo/blob/master/CHANGELOG.md for other notable changes.
EOL
    end

    def mv(src, dest)
      puts "mv #{src} #{dest}"
      FileUtils.mv(src, dest)
    end
  end
end
