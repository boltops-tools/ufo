module Ufo::Cfn::Stack::Builder::Resources::SecurityGroup
  class Ecs < Base
    def build
      return unless managed_security_groups?

      {
        Type: "AWS::EC2::SecurityGroup",
        Properties: properties
      }
    end

    def properties
      props = {
        GroupDescription: "Allow http to client host",
        VpcId: {Ref: "Vpc"},
        SecurityGroupEgress: [
          {
            IpProtocol: "-1",
            CidrIp: "0.0.0.0/0",
            Description: "outbound traffic"
          }
        ],
        Tags: [
          {
            Key: "Name",
            Value: @stack_name,
          }
        ]
      }

      if vars[:elb_type] == "network"
        props[:SecurityGroupIngress] = {
          IpProtocol: "tcp",
          FromPort: vars[:container][:port],
          ToPort: vars[:container][:port],
          CidrIp: "0.0.0.0/0",
          Description: "docker ephemeral port range for network elb",
        }
      end

      props
    end
  end
end
