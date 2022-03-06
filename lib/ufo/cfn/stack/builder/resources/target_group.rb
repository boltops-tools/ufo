class Ufo::Cfn::Stack::Builder::Resources
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
        Protocol: vars[:default_target_group_protocol],
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

      props[:TargetType] = "ip" if vars[:container][:network_mode] == "awsvpc"
      props[:HealthCheckPort] = vars[:container][:port] if vars[:elb_type] == "network" && vars[:network_mode] == "awsvpc"
      props[:HealthCheckPath] = health_check_path
      props[:HealthCheckIntervalSeconds] = health_check_interval_seconds
      props[:HealthyThresholdCount] = healthy_threshold_count
      props[:UnhealthyThresholdCount] = unhealthy_threshold_count

      props
    end

    meths = %w[
      health_check_interval_seconds
      health_check_path
      healthy_threshold_count
      unhealthy_threshold_count
    ]
    delegate *meths, to: :elb
    def elb
      Ufo.config.elb
    end
  end
end
