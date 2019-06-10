module Ufo
  class Network < Command
    def self.cli_options
      [
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files."],
        [:ecs_subnets, type: :array, desc: "ECS Subnets"],
        [:elb_subnets, type: :array, desc: "ELB Subnets"],
        [:vpc_id, desc: "Vpc id"],
        [:filename, default: "default", desc: "Name of the settings file to create w/o extension."],
      ]
    end

    cli_options.each { |o| option(*o) }

    desc "init", "Creates network starter settings file."
    long_desc Help.text("network:init")
    def init
      Init.start
    end
  end
end
