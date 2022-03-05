module Ufo
  class TaskDefinition
    extend Memoist
    include Ufo::Concerns # for names

    attr_reader :name, :role
    def initialize(options={})
      @options = options
      @role = Ufo.role
      @name = names.task_definition # IE: :APP-:ROLE-:ENV => demo-web-dev
    end

    def path
      expr = "#{Ufo.root}/.ufo/resources/task_definitions/{#{@role},web,default}.{json,yml}"
      Dir.glob(expr).first
    end
    memoize :path
  end
end
