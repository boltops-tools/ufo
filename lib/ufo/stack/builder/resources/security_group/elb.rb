module Ufo::Stack::Builder::Resources::SecurityGroup
  class Elb < Base
    def build
      return unless managed_security_groups_enabled?
      return unless @elb_type == "application"

      {
        Type: "AWS::EC2::SecurityGroup",
        Condition: "CreateElbIsTrue",
        Properties: properties
      }
    end

    def properties
      port = cfn.dig(:Listener, :Port) || cfn.dig(:listener, :port) # backwards compatiblity

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

      if @create_listener_ssl
        ssl_port = cfn.dig(:ListenerSsl, :Port) || cfn.dig(:listener_ssl, :port) # backwards compatiblity
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
