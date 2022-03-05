class Ufo::TaskDefinition
  module Context
    include DslEvaluator
    include Helpers

    def load_context
      load_variables
      load_custom_helpers
    end

    def load_variables
      layers = Ufo::Layering::Layer.new(@task_definition).paths
      layers.each do |layer|
        evaluate_file(layer)
      end
    end

    def load_custom_helpers
      load_helper_files("#{Ufo.root}/.ufo/helpers")
    end

    # Load custom project helper methods
    def load_helper_files(dir)
      paths = Dir.glob("#{dir}/**/*.rb")
      paths.sort_by! { |p| p.size } # so namespaces are loaded first
      paths.each do |path|
        next unless File.file?(path)

        filename = path.sub(%r{.*/helpers/},'').sub('.rb','')
        module_name = filename.camelize

        # Prepend a period so require works when UFO_ROOT is set to a relative path without a period.
        #   Example: UFO_ROOT=tmp/ufo_project
        first_char = path[0..0]
        path = "./#{path}" unless %w[. /].include?(first_char)

        # Examples:
        #     path:        .ufo/helpers/custom_helper.rb
        #     module_name: CustomHelper
        require path
        self.class.send :include, module_name.constantize
      end
    end
  end
end
