require 'yaml'

module Ufo
  class Param
    extend Memoist

    def initialize
      @params_path = "#{Ufo.root}/.ufo/params.yml"
    end

    def data
      return {} unless File.exist?(@params_path)

      result = RenderMePretty.result(@params_path, context: template_scope)
      data = YAML.load(result) || {}
      data.deep_symbolize_keys
    end
    memoize :data

    def template_scope
      self
    end
  end
end
