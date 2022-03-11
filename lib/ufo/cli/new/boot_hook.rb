class Ufo::CLI::New
  class BootHook < Sequence
    def self.cli_options
      [
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files"],
      ]
    end
    cli_options.each do |args|
      class_option(*args)
    end

    def set_source
      set_template_source "boot_hook"
    end

    def create_helper
      logger.info "=> Creating boot_hook"
      directory ".", "."
    end
  end
end
