module Ufo
  class Balancer < Command
    autoload :Init, "ufo/balancer/init"

    def self.cli_options
      [
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files."],
        [:subnets, type: :array, default: ["subnet-REPLACE-ME"], desc: "Subnets"],
        [:security_groups, type: :array, default: [], desc: "Security groups"],
        [:vpc_id, default: "vpc-REPLACE-ME", desc: "Vpc id"],
      ]
    end

    cli_options.each do |o|
      option *o
    end

    desc "init", "Creates balancer starter files."
    long_desc Help.text("balancer:init")
    def init
      pp options
      Init.start
    end
  end
end
