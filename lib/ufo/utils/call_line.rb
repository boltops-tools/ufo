module Ufo::Utils
  module CallLine
    include Pretty

    def ufo_call_line
      caller.find { |l| l.include?('.ufo/') }
    end
  end
end

