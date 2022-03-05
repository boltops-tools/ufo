class Ufo::CLI::New
  module Concerns
    extend ActiveSupport::Concern

  private
    def class_name
      name.underscore.camelize
    end

    # Files should be named with underscores instead of dashes even though project name can contain a dash.
    # This is because autoloading works with underscores in the filenames only.
    def underscore_name
      name.underscore
    end
  end
end
