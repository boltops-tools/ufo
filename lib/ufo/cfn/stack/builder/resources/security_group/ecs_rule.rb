module Ufo::Cfn::Stack::Builder::Resources::SecurityGroup
  class EcsRule < Base
    def build
      return unless manage_ecs_security_group?

      {
        Type: "AWS::EC2::SecurityGroupIngress",
        Condition: "CreateElbIsTrue",
        Properties: {
          IpProtocol: "tcp",
          FromPort: "0",
          ToPort: "65535",
          SourceSecurityGroupId: {
            "Fn::GetAtt": "ElbSecurityGroup.GroupId"
          },
          GroupId: {
            "Fn::GetAtt": "EcsSecurityGroup.GroupId"
          },
          Description: "application elb access to ecs"
        }
      }
    end
  end
end
