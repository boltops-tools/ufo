Displays information about the service.

## Examples

    $ ufo resources demo-web
    Resources:
    Ecs - AWS::ECS::Service:
      arn:aws:ecs:us-east-1:111111111111:service/dev-demo-web-Ecs-KN8OVQ7L2N40
    EcsCrossSecurityGroupRule - AWS::EC2::SecurityGroupIngress:
      EcsCrossSecurityGroupRule
    EcsSecurityGroup - AWS::EC2::SecurityGroup:
      sg-63c17228
    Elb - AWS::ElasticLoadBalancingV2::LoadBalancer:
      arn:aws:elasticloadbalancing:us-east-1:111111111111:loadbalancer/app/dev-hi-Elb-1KEVRDILLSUC9/0b9434b7a9a66fb7
    ElbSecurityGroup - AWS::EC2::SecurityGroup:
      sg-11b1025a
    Listener - AWS::ElasticLoadBalancingV2::Listener:
      arn:aws:elasticloadbalancing:us-east-1:111111111111:listener/app/dev-hi-Elb-1KEVRDILLSUC9/0b9434b7a9a66fb7/1996f1f252d7ba2e
    TargetGroup - AWS::ElasticLoadBalancingV2::TargetGroup:
      arn:aws:elasticloadbalancing:us-east-1:111111111111:targetgroup/dev-h-Targe-1VUFA8577XWT7/7e67276c182fdc87
