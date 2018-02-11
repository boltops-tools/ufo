require 'ostruct'

module Ufo
  autoload :TaskDefinition, 'ufo/dsl/task_definition'
  autoload :Outputter, 'ufo/dsl/outputter'
  autoload :Helper, 'ufo/dsl/helper'

  class DSL
    def initialize(template_definitions_path, options={})
      @template_definitions_path = template_definitions_path
      @options = options
      @task_definitions = []
      @outputters = []
    end

    def run
      evaluate_template_definitions
      build_task_definitions
      write_outputs
    end

    # All we're doing at this point is saving blocks of code into memory
    # The instance_eval provides the task_definition and helper methods as they are part
    # of this class.
    def evaluate_template_definitions
      source_code = IO.read(@template_definitions_path)
      begin
        instance_eval(source_code, @template_definitions_path)
      rescue Exception => e
        task_definition_error(e)
        puts "\nFull error:"
        raise
      end
    end

    # Prints out a user friendly task_definition error message
    def task_definition_error(e)
      error_info = e.backtrace.first
      path, line_no, _ = error_info.split(':')
      line_no = line_no.to_i
      puts "Error evaluating #{path}:".colorize(:red)
      puts e.message
      puts "Here's the line in #{path} with the error:\n\n"

      contents = IO.read(path)
      content_lines = contents.split("\n")
      context = 5 # lines of context
      top, bottom = [line_no-context-1, 0].max, line_no+context-1
      spacing = content_lines.size.to_s.size
      content_lines[top..bottom].each_with_index do |line_content, index|
        line_number = top+index+1
        if line_number == line_no
          printf("%#{spacing}d %s\n".colorize(:red), line_number, line_content)
        else
          printf("%#{spacing}d %s\n", line_number, line_content)
        end
      end
    end

    def build_task_definitions
      puts "Generating Task Definitions:" unless @options[:quiet]
      clean_existing_task_definitions
      @task_definitions.each do |task|
        erb_result = task.build
        @outputters << Outputter.new(task.task_definition_name, erb_result, @options)
      end
    end

    def clean_existing_task_definitions
      # removing 1 file a a time instead of recursing removing the directory to be safe
      Dir.glob("#{Ufo.root}/ufo/output/*").each do |path|
        FileUtils.rm_f(path)
      end
    end

    def write_outputs
      @outputters.each do |outputter|
        outputter.write
      end
    end

    # methods available in task_definitions
    def task_definition(name, &block)
      @task_definitions << TaskDefinition.new(self, name, @options, &block)
    end

    def helper
      Helper.new(@options)
    end
  end
end
