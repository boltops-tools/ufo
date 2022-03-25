class Ufo::CLI::New
  class Hook < Sequence
    argument :type, default: "ufo", description: "IE: docker, ufo" # description doesnt really show up

    def self.cli_options
      [
        [:force, aliases: ["y"], type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files"],
      ]
    end
    cli_options.each { |args| class_option(*args) }

  public
    def create_hook
      set_template_source("hooks")
      template "#{type}.rb", ".ufo/config/hooks/#{type}.rb"
    end
  end
end
