module Ufo
  class Balancer < Command
    autoload :Init, "ufo/balancer/init"

    def self.cli_options
      [
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files."],
        [:launch_type, desc: "Launch type: ec2 or fargate."],
        [:subnets, type: :array, desc: "Subnets"],
        [:security_groups, type: :array, desc: "Security groups"],
        [:vpc_id, desc: "Vpc id"],
      ]
    end

    cli_options.each do |o|
      option *o
    end

    desc "init", "Creates balancer starter file."
    long_desc Help.text("balancer:init")
    def init
      Init.start
    end
  end
end
