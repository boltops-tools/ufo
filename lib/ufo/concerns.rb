module Ufo
  module Concerns
    extend Memoist
    include Names

    def build
      Ufo::CLI::Build.new(@options)
    end
    memoize :build

    def deploy
      Ufo::Cfn::Deploy.new(@options)
    end
    memoize :deploy

    def info
      Ufo::Info.new(@options)
    end
    memoize :info

    def ps
      Ufo::CLI::Ps.new(@options)
    end
    memoize :ps
  end
end
