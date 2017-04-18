require 'ostruct'

module Ufo
  autoload :TaskDefinition, 'ufo/dsl/task_definition'
  autoload :Outputter, 'ufo/dsl/outputter'
  autoload :Helper, 'ufo/dsl/helper'

  class DSL
    def initialize(template_definitions_path, options={})
      @template_definitions_path = template_definitions_path
      @options = options
      @project_root = options[:project_root] || '.'
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
      instance_eval(source_code, @template_definitions_path)
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
      Dir.glob("#{@options[:project_root]}/ufo/output/*").each do |path|
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
