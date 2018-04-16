require 'yaml'
require 'memoist'

module Ufo
  class Param
    extend Memoist

    def initialize
      @params_path = "#{Ufo.root}/.ufo/params.yml"
    end

    def helper
      dsl = DSL.new("#{Ufo.root}/.ufo/task_definitions.rb", quiet: true, mute: true)
      dsl.helper
    end

    def data
      vars = Ufo::TemplateScope.new(helper).assign_instance_variables
      result = RenderMePretty.result(@params_path, vars)
      YAML.load(result)
    end
    memoize :data
  end
end
