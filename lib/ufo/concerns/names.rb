module Ufo::Concerns
  module Names
    extend Memoist
    def names
      Ufo::Names.new
    end
    memoize :names
  end
end
