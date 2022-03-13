class Ufo::Cfn::Stack
  class Vpc < Ufo::Cfn::Base
    extend Memoist
    include Ufo::TaskDefinition::Helpers

    def id
      vpc.id if vpc.id # nil means ECS Service uses default VPC
    end
    alias_method :vpc_id, :id

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
        subnets_for(vpc_id).join(',') if id # nil means ECS Service uses default subnets
      end
    end

  private
    def vpc
      Ufo.config.vpc
    end
  end
end
