module Ufo
  module Settings
    extend Memoist

    def network
      Ufo::Setting::Profile.new(:network, settings[:network_profile]).data
    end
    memoize :network

    def cfn
      Ufo::Setting::Profile.new(:cfn, settings[:cfn_profile]).data
    end
    memoize :cfn

    def settings
      Setting.new.data
    end
    memoize :settings
  end
end
