require "erb"
require "json"

module Ufo
  class DSL
    class TaskDefinition
      attr_reader :task_definition_name
      def initialize(dsl, task_definition_name, options={}, &block)
        @dsl = dsl
        @task_definition_name = task_definition_name
        @block = block
        @options = options
      end

      # delegate helper method back up to dsl
      def helper
        @dsl.helper
      end

      def build
        load_variables
        instance_eval(&@block)

        hash = assign_instance_variables
        RenderMePretty.result(source_path, hash)
      end

      def assign_instance_variables
        # copy over the instance variables from TaskDefinition scope to RenderMePretty's scope
        hash = {}
        instance_variables.each do |var|
          key = var.to_s.sub('@','') # rid of the leading @
          hash[key.to_sym] = instance_variable_get(var)
        end
        hash
      end

      def load_variables
        load_variables_file("base")
        load_variables_file(Ufo.env)
      end

      # Load the variables defined in ufo/variables/* to make available in the
      # template blocks in ufo/templates/*.
      #
      # Example:
      #
      #   `ufo/variables/base.rb`:
      #     @name = "docker-process-name"
      #     @image = "docker-image-name"
      #
      #   `ufo/templates/main.json.erb`:
      #   {
      #     "containerDefinitions": [
      #       {
      #          "name": "<%= @name %>",
      #          "image": "<%= @image %>",
      #      ....
      #   }
      #
      # NOTE: Only able to make instance variables avaialble with instance_eval
      #   Wasnt able to make local variables available.
      def load_variables_file(filename)
        path = "#{Ufo.root}/.ufo/variables/#{filename}.rb"
        instance_eval(IO.read(path)) if File.exist?(path)
      end

      # at this point instance_eval has been called and source has possibly been called
      def source(name)
        @source = name
      end

      def variables(vars={})
        vars.each do |var,value|
          if instance_variable_defined?("@#{var}")
            puts "WARNING: The instance variable @#{var} is already used internally with ufo.  Please name you variable another name!"
          end
          instance_variable_set("@#{var}", value)
        end
      end

      def source_path
        if @source # this means that source has been called
          path = "#{Ufo.root}/.ufo/templates/#{@source}.json.erb"
          check_source_path(path)
        else
          # default source path
          path = File.expand_path("../../templates/default.json.erb", __FILE__)
          puts "#{task_definition_name} template definition using default template: #{path}" unless @options[:mute]
        end
        path
      end

      def check_source_path(path)
        unless File.exist?(path)
          friendly_path = path.sub("#{Ufo.root}/", '')
          puts "ERROR: Could not find the #{friendly_path} template.  Are sure it exists?  Check where you called source in ufo/task_definitions.rb"
          exit 1
        else
          puts "#{task_definition_name} template definition using project template: #{path}" unless @options[:mute]
        end
        path
      end
    end
  end
end
