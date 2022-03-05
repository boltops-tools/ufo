module Ufo::Cfn::Stack::Builder::Resources::SecurityGroup
  class Elb < Base
    def build
      return unless managed_security_groups?
      return unless vars[:elb_type] == "application"

      {
        Type: "AWS::EC2::SecurityGroup",
        Condition: "CreateElbIsTrue",
        Properties: properties
      }
    end

    def properties
      port = Ufo.config.elb.port # 80
      props = {
        GroupDescription: "Allow http to client host",
        VpcId: {Ref: "Vpc"},
        SecurityGroupIngress: [
          {
            IpProtocol: "tcp",
            FromPort: port,
            ToPort: port,
            CidrIp: "0.0.0.0/0"
          }
        ],
        SecurityGroupEgress: [
          {
            IpProtocol: "tcp",
            FromPort: "0",
            ToPort: "65535",
            CidrIp: "0.0.0.0/0"
          }
        ],
        Tags: [
          {
            Key: "Name",
            Value: "#{@stack_name}-elb"
          }
        ]
      }

      if vars[:create_listener_ssl]
        ssl_port = Ufo.config.elb.ssl.port
        props[:SecurityGroupIngress] << {
          IpProtocol: "tcp",
          FromPort: ssl_port,
          ToPort: ssl_port,
          CidrIp: "0.0.0.0/0"
        }
      end

      props
    end
  end
end
