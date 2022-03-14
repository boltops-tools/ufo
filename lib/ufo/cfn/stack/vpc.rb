class Ufo::Cfn::Stack
  class Vpc < Ufo::Cfn::Base
    extend Memoist
    include Ufo::TaskDefinition::Helpers

    def id
      vpc.id ? vpc.id : default_vpc
    end
    alias_method :vpc_id, :id

    def vpc
      Ufo.config.vpc
    end

    def elb_subnets
      subnets(vpc.subnets.elb)
    end

    def ecs_subnets
      subnets(vpc.subnets.ecs)
    end

    def subnets(subnets)
      if subnets
        subnets.is_a?(String) ? subnets : subnets.join(',')
      else
        subnets_for(vpc_id).join(',') # default vpc subnets or all subnets for the configured vpc
      end
    end
  end
end
