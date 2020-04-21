module Ufo
  class Tasks::Builder
    # ship: build and registers task definitions together
    def self.ship(task_definition, options)
      # When handling task definitions in with the ship command and class, we always want to
      # build and register task definitions. There is little point of running them independently
      # This method helps us do that.
      build(options)
    end

    # ship: build and registers task definitions together
    def self.build(options)
      Tasks::Builder.new(options).build
    end

    def initialize(options={})
      @options = options
    end

    def build
      puts "Building Task Definitions...".color(:green) unless @options[:mute]
      check_templates_definitions_path
      dsl = DSL.new(template_definitions_path, @options.merge(quiet: false, mute: true))
      dsl.run
      puts "Task Definitions built in .ufo/output" unless @options[:mute]
    end

    def check_templates_definitions_path
      unless File.exist?(template_definitions_path)
        pretty_path = template_definitions_path.sub("#{Ufo.root}/", '')
        puts "ERROR: #{pretty_path} does not exist.  Run: `ufo init` to create a starter file" unless @options[:mute]
        exit 1
      end
    end

    def template_definitions_path
      "#{Ufo.root}/.ufo/task_definitions.rb"
    end
  end
end
