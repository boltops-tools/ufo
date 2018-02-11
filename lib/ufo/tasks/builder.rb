module Ufo
  class Tasks::Builder
    # build and registers together
    def self.register(task_definition, options)
      # task definition and deploy logic are coupled in the Ship class.
      # Example: We need to know if the task defintion is a web service to see if we need to
      # add the elb target group.  The web service information is in the Tasks::Builder
      # and the elb target group gets set in the Ship class.
      # So we always call these together.
      Tasks::Builder.new(options).build
      Tasks::Register.register(task_definition, options)
    end

    def initialize(options={})
      @options = options
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
        pretty_path = template_definitions_path.sub("#{Ufo.root}/", '')
        puts "ERROR: #{pretty_path} does not exist.  Run: `ufo init` to create a starter file" unless @options[:mute]
        exit 1
      end
    end

    def template_definitions_path
      "#{Ufo.root}/ufo/task_definitions.rb"
    end
  end
end
