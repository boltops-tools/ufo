module Ufo
  class Network < Command
    autoload :Init, "ufo/network/init"
    autoload :Helper, "ufo/network/helper"
    autoload :Setting, "ufo/network/setting"

    def self.cli_options
      [
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files."],
        [:subnets, type: :array, desc: "Subnets"],
        [:vpc_id, desc: "Vpc id"],
        [:profile_name, default: "default", desc: "Name of the profile file to create."],
      ]
    end

    cli_options.each do |o|
      option *o
    end

    desc "init", "Creates network starter settings file."
    long_desc Help.text("network:init")
    def init
      Init.start
    end
  end
end
