class Ufo::Stack::Builder::Resources
  class Listener < Base
    def build
      {
        Type: "AWS::ElasticLoadBalancingV2::Listener",
        Condition: "CreateElbIsTrue",
        Properties: properties,
      }
    end

    def properties
      props = {
        DefaultActions: [
          {
            Type: "forward",
            TargetGroupArn: {
              "Fn::If": [
                "ElbTargetGroupIsBlank",
                {Ref: "TargetGroup"},
                {Ref: "ElbTargetGroup"}
              ]
            }
          }
        ],
        LoadBalancerArn: {Ref: "Elb"},
        Protocol: protocol,
      }

      props[:Port] = port if port

      props
    end

    def protocol
      @default_listener_protocol
    end

    def port
      80
    end
  end
end
