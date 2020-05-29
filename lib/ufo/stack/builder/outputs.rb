class Ufo::Stack::Builder
  class Outputs < Base
    def build
      outputs = {
        ElbDns: {
          Description: "Elb Dns",
          Condition: "CreateElbIsTrue",
          Value: {
            "Fn::GetAtt": "Elb.DNSName"
          }
        }
      }

      if @create_route53
        outputs[:Route53Dns] = {
          Description: "Route53 Dns",
          Value: {Ref: "Dns"},
        }
      end

      outputs
    end
  end
end
