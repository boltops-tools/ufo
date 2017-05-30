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
        erb_result(source_path)
      end

      def erb_result(path)
        template = IO.read(path)
        begin
          ERB.new(template, nil, "-").result(binding)
        rescue Exception => e
          puts e

          # how to know where ERB stopped? - https://www.ruby-forum.com/topic/182051
          # syntax errors have the (erb):xxx info in e.message
          # undefined variables have (erb):xxx info in e.backtrac
          error_info = e.message.split("\n").grep(/\(erb\)/)[0]
          error_info ||= e.backtrace.grep(/\(erb\)/)[0]
          raise unless error_info # unable to find the (erb):xxx: error line
          line = error_info.split(':')[1].to_i
          puts "Error evaluating ERB template on line #{line.to_s.colorize(:red)} of: #{path.sub(/^\.\//, '')}"

          template_lines = template.split("\n")
          context = 5 # lines of context
          top, bottom = [line-context-1, 0].max, line+context-1
          spacing = template_lines.size.to_s.size
          template_lines[top..bottom].each_with_index do |line_content, index|
            line_number = top+index+1
            if line_number == line
              printf("%#{spacing}d %s\n".colorize(:red), line_number, line_content)
            else
              printf("%#{spacing}d %s\n", line_number, line_content)
            end
          end
          exit 1 unless ENV['TEST']
        end
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
