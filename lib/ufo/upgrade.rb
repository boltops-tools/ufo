module Ufo
  class Upgrade < Command
    desc "v2to3", "Upgrade from version 2 to 3."
    def v2to3
      Upgrade3.new(options).run
    end

    desc "v33to34", "Upgrade from version 3.3 to 3.4"
    def v33to34
      Upgrade33to34.new(options).run
    end

    def self.options
      [
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files."],
        [:vpc_id, desc: "Vpc id"],
        [:ecs_subnets, type: :array, desc: "Subnets for ECS tasks, defaults to --elb-subnets set to"],
        [:elb_subnets, type: :array, desc: "Subnets for ELB"],
      ]
    end
    options.each { |o| option(*o) }
    desc "v3to4", "Upgrade from version 3 to 4."
    long_desc Help.text('upgrade/v3to4')
    def v3to4
      Upgrade4.start
    end

    desc "v43to45", "Upgrade from version 4.3 and 4.4 to 4.5"
    def v43to45
      Upgrade43to45.new(options).run
    end
  end
end
