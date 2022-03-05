module Ufo::Cfn::Stack::Builder::Resources::Scaling
  class Role < Base
    def build
      return unless autoscaling_enabled?

      text =<<~EOL
        Type: AWS::IAM::Role
        Properties:
          AssumeRolePolicyDocument:
            Statement:
              - Effect: Allow
                Principal:
                  Service: [application-autoscaling.amazonaws.com]
                Action: ["sts:AssumeRole"]
          Policies:
            - PolicyName: !Sub "${AWS::StackName}-auto-scaling-policy"
              PolicyDocument:
                Version: "2012-10-17"
                Statement:
                  - Effect: Allow
                    Action:
                      - ecs:DescribeServices
                      - ecs:UpdateService
                      - cloudwatch:PutMetricAlarm
                      - cloudwatch:DescribeAlarms
                      - cloudwatch:DeleteAlarms
                    Resource:
                      - "*"
      EOL
      Ufo::Yaml.load(text).deep_symbolize_keys
    end
  end
end
