class Ufo::CLI::Central
  class Base
    include Ufo::Utils::Execute
    include Ufo::Utils::Logging
    include Ufo::Utils::Pretty
    include Ufo::Utils::Sure

    def initialize(options={})
      @options = options
    end
  end
end
