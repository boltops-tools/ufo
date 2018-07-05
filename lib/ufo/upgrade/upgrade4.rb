require 'fileutils'
require 'yaml'

class Ufo::Upgrade
  class Upgrade4 < Ufo::Sequence
    include Ufo::Network::Helper

    Ufo::Upgrade.options.each { |o| class_option(*o) }

    def already_ufo4_check
      if File.exist?("#{Ufo.root}/.ufo/settings/network/default.yml")
        puts "It looks like you already have a .ufo/settings/network/default.yml file in your project. The current folder already contains the new project structure for ufo version 4. Exiting without updating anything."
        exit
      end

      if !File.exist?("#{Ufo.root}/.ufo")
        puts "Could not find a ufo folder in your project at all. Maybe you want to run ufo init to initialize a new ufo project instead?"
        exit
      end
    end

    def upgrade
      puts "Upgrading structure of your current project to the new ufo version 4 project structure"
      upsert_dockerignore
      upsert_gitignore
      update_params_yaml
      update_task_definitions
      new_files
    end

    def final_message
      puts "Upgrade complete.\n\n"
      new_env_info
    end

  private
    def update_task_definitions
      text = <<-EOL
    # HINT: shows how Ufo.env_extra can to create different log groups
    # awslogs_group: ["ecs/TASK_DEFINITION_NAME", Ufo.env_extra].compact.join('-'),
EOL
      insert_into_file ".ufo/task_definitions.rb", text, :before => /    awslogs_group:/
    end

    def new_files
      configure_network_settings
      template(".ufo/settings/network/default.yml")
      template(".ufo/settings/cfn/default.yml")
    end

    # remove the create_service and update_service sections
    def update_params_yaml
      if File.exist?("#{Ufo.root}/.ufo/params.yml")
        update_params_yaml_existing
      else
        update_params_yaml_new
      end
    end

    def update_params_yaml_existing
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

      # provides hint to user on the new helper network method
      new_run_task = <<-EOL

# Hint: Shows new network method to set subnets.
# run_task:
#   network_configuration:
#     awsvpc_configuration:
#       subnets: <%= network[:ecs_subnets].inspect %> # required
#       security_groups: <%= network[:ecs_security_groups].inspect %>
#       # for fargate use: assign_public_ip: "ENABLED"
#       # assign_public_ip: "ENABLED" # accepts ENABLED, DISABLED

EOL
      insert_into_file ".ufo/params.yml", new_run_task, :before => "run_task:\n"
    end

    def update_params_yaml_new
      template ".ufo/params.yml"
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
.ufo/log
.ufo/output
EOL
      if File.exist?(".gitignore")
        append_to_file ".gitignore", text
      else
        create_file ".gitignore", text
      end
    end

    def new_env_info
      puts <<-EOL
Congratulations, your project has been upgraded to ufo version 4. A major change in ufo from version 3 to 4 is that the ECS service is now created and managed by CloudFormation. So when you deploy your service with ufo version 4 for the first time it will create a new additional ECS service. To create the new ECS service, use the same command:

    ufo ship SERVICE

After the new ECS service is created and tested, you can switch the DNS over to it. Destroy the old ECS service with the ECS console when you are confident. More details of the upgrade process are here https://ufoships.com/docs/upgrade4/

Also, in ufo version 4 you can shorten most ufo commands with the ufo current command.  Example:

    ufo ship my-service
    ufo current --service my-service
    ufo ship # same as ufo ship my-service now

Refer to http://ufoships.com/reference/ufo-current/ for more info.

Also, refer to https://github.com/tongueroo/ufo/blob/master/CHANGELOG.md for other version 4 notable changes.
EOL
    end

    def mv(src, dest)
      puts "mv #{src} #{dest}"
      FileUtils.mv(src, dest)
    end
  end
end
