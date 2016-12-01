module Ufo
  autoload :DSL, 'ufo/dsl'

  class TasksBuilder
    def initialize(options={})
      @options = options
      @project_root = options[:project_root] || '.'
    end

    def build
      puts "Building Task Definitions...".green unless @options[:mute]
      check_templates_definitions_path
      dsl = DSL.new(template_definitions_path, @options.merge(quiet: false, mute: true))
      dsl.run
      puts "Task Definitions built in ufo/output." unless @options[:mute]
    end

    def check_templates_definitions_path
      unless File.exist?(template_definitions_path)
        pretty_path = template_definitions_path.sub("#{@project_root}/", '')
        puts "ERROR: #{pretty_path} does not exist.  Run: `ufo init` to create a starter file" unless @options[:mute]
        exit 1
      end
    end

    def template_definitions_path
      "#{@project_root}/ufo/task_definitions.rb"
    end
  end
end
