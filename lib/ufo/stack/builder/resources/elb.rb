class Ufo::Stack::Builder::Resources
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
        Type: @elb_type,
        Tags: [
          {Key: "Name", Value: @stack_name}
        ],
        Subnets: {Ref: "ElbSubnets"},
        Scheme: "internet-facing"
      }

      props[:SecurityGroups] = security_groups(:elb) if @elb_type == "application"
      subnets(props)

      props
    end

    def subnets(props)
      mappings = @elb_type == "network" && @subnet_mappings && !@subnet_mappings.empty?
      if mappings
        props[:SubnetMappings] = subnet_mappings
      else
        props[:Subnets] = {Ref: "ElbSubnets"}
      end
    end

    def subnet_mappings
      @subnet_mappings.map do |allocation_id, subnet_id|
        {
          AllocationId: allocation_id,
          SubnetId: subnet_id,
        }
      end
    end
  end
end
