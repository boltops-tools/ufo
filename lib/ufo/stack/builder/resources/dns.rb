class Ufo::Stack::Builder::Resources
  class Dns < Base
    def build
      return unless @create_route53

      {
        Type: "AWS::Route53::RecordSet",
        Properties: {
          Comment: "cname to load balancer",
          Type: "CNAME",
          TTL: 60, # ttl has special casing
          ResourceRecords: [{"Fn::GetAtt": "Elb.DNSName"}]
        }
      }
    end
  end
end
