class Ufo::CLI::New
  class Helper < Sequence
    # required for name => underscore_name => .ufo/helpers/%underscore_name%_helper.rb.tt
    argument :name, default: "custom"

    def self.cli_options
      [
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files"],
      ]
    end
    cli_options.each do |args|
      class_option(*args)
    end

    def set_source
      set_template_source "helper"
    end

    def create_helper
      logger.info "=> Creating #{name}_helper.rb"
      directory ".", ".ufo/helpers"
    end
  end
end
