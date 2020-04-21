class Ufo::Stack::Builder::Resources
  class TargetGroup < Base
    def build
      {
        Type: "AWS::ElasticLoadBalancingV2::TargetGroup",
        Condition: "CreateTargetGroupIsTrue",
        Properties: properties,
      }
    end

    def properties
      props = {
        VpcId: {Ref: "Vpc"},
        Tags: [
          {
            Key: "Name",
            Value: @stack_name,
          }
        ],
        Protocol: @default_target_group_protocol,
        Port: 80,
        HealthCheckIntervalSeconds: 10,
        HealthyThresholdCount: 2,
        UnhealthyThresholdCount: 2,
        TargetGroupAttributes: [
          {
            Key: "deregistration_delay.timeout_seconds",
            Value: 10
          }
        ]
      }

      props[:TargetType] = "ip" if @container[:network_mode] == "awsvpc"
      props[:HealthCheckPort] = @container[:port] if @elb_type == "network" && @network_mode == "awsvpc"

      props
    end
  end
end
