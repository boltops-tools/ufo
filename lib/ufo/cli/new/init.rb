class Ufo::CLI::New
  class Init < Sequence
    def self.options
      [
        [:app, aliases: :a, desc: "App name.  If not specified, it's inferred from the folder name"],
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files"],
        # note: aliases: :r messes up Usage help: ufo init -h so not using it
        [:repo, required: true, desc: "Docker repo to use. Example: ORG/REPO"],
      ]
    end
    options.each { |o| class_option(*o) }

    def set_source
      set_template_source("init")
      self.destination_root = '.'
    end

    def set_variables
      @app = options[:app] || inferred_app
      @repo = options[:repo]
    end

    def generate
      puts "Generating .ufo structure"
      directory "."
    end

    def update_gitignore
      text =<<~EOL
        .ufo/tmp
        .ufo/log
        .ufo/output
        .secrets
      EOL
      if File.exist?(".gitignore")
        append_to_file ".gitignore", text
      else
        create_file ".gitignore", text
      end
    end

    def update_dockerignore
      text = ".ufo\n"
      if File.exist?(".dockerignore")
        append_to_file ".dockerignore", text
      else
        create_file ".dockerignore", text
      end
    end

    def create_dockefile
      return if File.exist?("Dockerfile")
      set_template_source("docker")
      directory ".", "."
    end

    def user_message
      puts "Starter .ufo files created"
      puts <<~EOL
        Congrats. You have successfully set up your project with ufo.
        To deploy to ECS:

            ufo ship

      EOL
    end
  end
end
