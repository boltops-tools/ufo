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

      def template_scope
        @template_scope ||= Ufo::TemplateScope.new(helper, @task_definition_name)
      end

      def build
        copy_instance_variables
        begin
          instance_eval(&@block)
        rescue Exception => e
          build_error_info(e)
          raise
        end
        RenderMePretty.result(source_path, context: template_scope)
      end

      # Provide a slightly better error message to user when the task definition
      # code block is not evaluated successfully.
      def build_error_info(e)
        puts "ERROR: evaluating block for task_definition #{@task_definition_name}".color(:red)
        # The first line of the backtrace has the info of the file name. Example:
        # ./.ufo/task_definitions.rb:24:in `block in evaluate_template_definitions'
        info = e.backtrace[0]
        filename = info.split(':')[0..1].join(':')
        puts "Filename: #{filename}".color(:red)
      end


      # Copy the instance variables from TemplateScope to TaskDefinition
      # so that config/variables are available in the task_definition blocks also.
      # Example:
      #
      #   task_definition "my-app" do
      #     # make config/variables available here also
      #   end
      #
      # This allows possible collision but think it is worth it to have
      # variables available.
      def copy_instance_variables
        template_scope.instance_variables.each do |var|
          val = template_scope.instance_variable_get(var)
          instance_variable_set(var, val)
        end
      end

      # At this point instance_eval has been called and source has been possibly called
      def source(name)
        @source = name
      end

      def variables(vars={})
        vars.each do |var,value|
          # Warn when variable collides with internal variable, but dont warn
          # template_scope variables collision.
          if instance_variable_defined?("@#{var}") && !template_scope_instance_variable?(var)
            puts "WARNING: The instance variable @#{var} is already used internally with ufo.  Please name you variable another name!"
          end
          template_scope.instance_variable_set("@#{var}", value)
        end
      end

      def template_scope_instance_variable?(var)
        template_scope.instance_variables.include?("@#{var}".to_sym)
      end

      def source_path
        if @source # this means that source has been called
          path = "#{Ufo.root}/.ufo/templates/#{@source}.json.erb"
          check_source_path(path)
        else
          # default source path
          path = File.expand_path("../../default/templates/main.json.erb", __FILE__)
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
