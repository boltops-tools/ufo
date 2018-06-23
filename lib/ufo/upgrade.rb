module Ufo
  class Upgrade < Command
    autoload :Upgrade3, "ufo/upgrade/upgrade3"
    autoload :Upgrade33to34, "ufo/upgrade/upgrade33to34"

    desc "v2_to_3", "Upgrade from version 2 to 3."
    def v2_to_3
      Upgrade3.new(options).run
    end

    desc "v3_3_to_3_4", "Upgrade from version 3.3 to 3.4"
    def v3_3_to_3_4
      Upgrade33to34.new(options).run
    end
  end
end
