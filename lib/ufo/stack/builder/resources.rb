class Ufo::Stack::Builder
  class Resources < Base
    def build
      {
        Dns: Dns.build,
        Ecs: Ecs.build,
        EcsSecurityGroup: SecurityGroup::Ecs.build,
        EcsSecurityGroupRule: SecurityGroup::EcsRule.build,
        Elb: Elb.build,
        ElbSecurityGroup: SecurityGroup::Elb.build,
        ExecutionRole: Roles::ExecutionRole.build,
        Listener: Listener.build,
        ListenerSsl: ListenerSsl.build,
        TargetGroup: TargetGroup.build,
        TaskDefinition: TaskDefinition.build,
        TaskRole: Roles::TaskRole.build,
      }
    end
  end
end
