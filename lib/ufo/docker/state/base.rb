class Ufo::Docker::State
  class Base
    include Ufo::Utils::Logging
    include Ufo::Utils::Pretty

    def initialize(options={})
      @options = options
      # base_image only passed in with: ufo docker base
      # State#update uses it.
      # State#read wont have access to it and gets it from stored state
      @base_image = options[:base_image]
    end
  end
end
