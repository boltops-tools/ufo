module Ufo::Utils
  module CallLine
    include Pretty

    def ufo_config_call_line
      call_line = caller.find { |l| l.include?('.ufo/') }
      pretty_path(call_line)
    end
  end
end

