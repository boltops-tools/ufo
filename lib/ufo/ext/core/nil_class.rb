require "json"

module Ufo
  refine NilClass do
    def to_json
      JSON.generate(self)
    end
  end
end

using Ufo
