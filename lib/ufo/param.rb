require 'yaml'
require 'memoist'

module Ufo
  class Param
    extend Memoist

    def initialize
      @params_path = "#{Ufo.root}/.ufo/params.yml"
    end

    def data
      YAML.load(IO.read(@params_path))
    end
    memoize :data
  end
end
