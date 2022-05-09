class Ufo::CLI::New
  class EnvFile < Sequence
    argument :type, default: "env", description: "IE: env or secrets" # description doesnt really show up

    def self.cli_options
      [
        [:force, aliases: ["y"], type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files"],
      ]
    end
    cli_options.each { |args| class_option(*args) }

  public
    def create_hook
      set_template_source("env_file")
      template "file.#{type}", ".ufo/env_files/#{Ufo.env}.#{type}"
    end
  end
end
