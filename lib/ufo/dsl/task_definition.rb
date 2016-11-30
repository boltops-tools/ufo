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
        @project_root = @options[:project_root] || '.'
      end

      # delegate helper method back up to dsl
      def helper
        @dsl.helper
      end

      def build
        instance_eval(&@block)
        erb_template = IO.read(source_path)
        ERB.new(erb_template).result(binding)
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
          path = "#{@project_root}/ufo/templates/#{@source}.json.erb"
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
          friendly_path = path.sub("#{@project_root}/", '')
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
