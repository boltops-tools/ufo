class Ufo::TaskDefinition
  class Builder < Ufo::CLI::Base
    def build
      Erb.new(@options).run
    end
  end
end
