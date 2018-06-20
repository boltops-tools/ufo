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
        [:vpc_id, desc: "Vpc id: for settings/network/default.yml."],
        [:fargate_security_groups, type: :array, desc: "Fargate security groups."],
      ]
    end
    cli_options.each do |args|
      class_option *args
    end

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
      directory ".", exclude_pattern: /(\.git|templates)/

      if @options[:launch_type] == "fargate"
        copy_file ".ufo/templates/fargate.json.erb", ".ufo/templates/main.json.erb"
      else
        copy_file ".ufo/templates/main.json.erb"
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

    def upsert_dockerignore
      text =<<-EOL
.ufo
EOL
      if File.exist?(".dockerignore")
        append_to_file ".dockerignore", text
      else
        create_file ".dockerignore", text
      end
    end

    def user_message
      puts "Starter ufo files created."
      puts <<-EOL
#{"="*64}
Congrats 🎉 You have successfully set up ufo for your project.

## Load Balancer Config

Ufo creates load balancer a using a starter profile file has been generated at: .ufo/.balancer/profiles/default.yml  The ELB settings are defaults that can be adjusted.  For more information about how to configure ufo for load balancer create, refer to: http://ufoships.com/docs/load-balancers/

To deploy to ECS:

  ufo ship #{@app}-web

## More customization

If you need to customize the ECS task definition to configure things like memory and cpu allocation. You can do this by adjusting the files the .ufo/variables folder. These variables get applied to the .ufo/templates/main.json.erb task definition json that is passed to the ECS register task definition api.

Some additional starter example roles for your apps were set up in in .ufo/task_definitions.rb.  Be sure to check it out and adjust it for your needs.

This allows you to fully customize and control your environment to fit your application's needs.

More info: http://ufoships.com
EOL
    end
  end
end
