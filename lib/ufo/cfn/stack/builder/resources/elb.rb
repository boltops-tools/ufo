class Ufo::Cfn::Stack::Builder::Resources
  class Elb < Base
    def build
      {
        Type: "AWS::ElasticLoadBalancingV2::LoadBalancer",
        Condition: "CreateElbIsTrue",
        Properties: properties,
      }
    end

    def properties
      props = {
        Type: vars[:elb_type],
        Tags: [
          {Key: "Name", Value: @stack_name}
        ],
        Scheme: "internet-facing"
      }

      props[:SecurityGroups] = security_groups(:elb) if vars[:elb_type] == "application"
      subnets(props)

      props
    end

    def subnets(props)
      mappings = Ufo.config.elb.subnet_mappings
      if mappings && vars[:elb_type] == "network"
        props[:SubnetMappings] = mappings
      else
        props[:Subnets] = {Ref: "ElbSubnets"}
      end
    end
  end
end
