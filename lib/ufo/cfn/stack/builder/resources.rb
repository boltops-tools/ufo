class Ufo::Cfn::Stack::Builder
  class Resources < Base
    def build
      {
        Dns: Dns.build(@options),
        EcsService: EcsService.build(@options),
        EcsSecurityGroup: SecurityGroup::Ecs.build(@options),
        EcsSecurityGroupRule: SecurityGroup::EcsRule.build(@options),
        Elb: Elb.build(@options),
        ElbSecurityGroup: SecurityGroup::Elb.build(@options),
        ExecutionRole: IamRoles::ExecutionRole.build(@options),
        Listener: Listener.build(@options),
        ListenerCertificate: ListenerCertificate.build(@options),
        ListenerSsl: ListenerSsl.build(@options),
        TargetGroup: TargetGroup.build(@options),
        TaskDefinition: TaskDefinition.build(@options),
        TaskRole: IamRoles::TaskRole.build(@options),
        # ECS Service AutoScaling
        ScalingRole: Scaling::Role.build(@options),
        ScalingTarget: Scaling::Target.build(@options),
        ScalingPolicy: Scaling::Policy.build(@options),
        # WAF Assocation
        WafAssociation: WafAssociation.build(@options),
      }
    end
  end
end
