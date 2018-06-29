module Ufo
  class Init < Sequence
    include Network::Helper

    # Ugly, this is how I can get the options from to match with this Thor::Group
    def self.cli_options
      [
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files."],
        [:image, required: true, desc: "Docker image name without the tag. Example: tongueroo/hi. Configures ufo/settings.yml"],
        [:app, required: true, desc: "App name. Preferably one word. Used in the generated ufo/task_definitions.rb."],
        [:launch_type, default: "ec2", desc: "ec2 or fargate."],
        [:execution_role_arn, desc: "execution role arn used by tasks, required for fargate."],
        [:template, desc: "Custom template to use."],
        [:template_mode, desc: "Template mode: replace or additive."],
        [:vpc_id, desc: "Vpc id. For settings/network/default.yml."],
        [:ecs_subnets, type: :array, desc: "Subnets for ECS tasks, defaults to --elb-subnets set to. For settings/network/default.yml"],
        [:elb_subnets, type: :array, desc: "Subnets for ELB. For settings/network/default.yml"],
      ]
    end
    cli_options.each { |o| class_option(*o) }

    def setup_template_repo
      return unless @options[:template]&.include?('/')

      sync_template_repo
    end

    def set_source_path
      return unless @options[:template]

      custom_template = "#{ENV['HOME']}/.ufo/templates/#{@options[:template]}"

      if @options[:template_mode] == "replace" # replace the template entirely
        override_source_paths(custom_template)
      else # additive: modify on top of default template
        default_template = File.expand_path("../../template", __FILE__)
        override_source_paths([custom_template, default_template])
      end
    end

    # for specs
    def set_destination_root
      return unless ENV['UFO_ROOT']

      dest = ENV['UFO_ROOT']
      FileUtils.rm_rf(dest) && FileUtils.mkdir_p(dest)
      self.destination_root = dest
      FileUtils.cd(dest)
    end

    def set_network_options
      configure_network_settings
    end

    def init_files
      # map variables
      @app = options[:app]
      @image = options[:image]
      @execution_role_arn_input = get_execution_role_arn_input
      # copy the files
      puts "Setting up ufo project..."
      directory ".", exclude_pattern: /(\.git)/
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

    def upsert_dockerignore
      text = ".ufo\n"
      if File.exist?(".dockerignore")
        append_to_file ".dockerignore", text
      else
        create_file ".dockerignore", text
      end
    end

    def user_message
      puts "Starter ufo files created."
      puts <<-EOL
Congrats 🎉 You have successfully set up ufo for your project.
#{"="*64}

## Task Definition Customizations

If you need to customize the ECS task definition to configure things like memory and cpu allocation. You can do this by adjusting the files the .ufo/variables folder. These variables get applied to the .ufo/templates/main.json.erb task definition json that is passed to the ECS register task definition api.

Some additional starter example roles for your apps were set up in in .ufo/task_definitions.rb.  Be sure to check it out and adjust it for your needs.

## Settings files

Additionally, ufo generated starter settings files at that further allow you to customize more settings.

* .ufo/settings.yml: general settings.
* .ufo/settings/cfn/default.yml: properties of CloudFormation resources that ufo creates.
* .ufo/settings/network/default.yml: network settings.

More more info refer to: http://ufoships.com/docs/settings/

To deploy to ECS:

  ufo ship #{@app}-web

EOL
    end
  end
end
