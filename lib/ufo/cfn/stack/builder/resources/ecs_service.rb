class Ufo::Cfn::Stack::Builder::Resources
  class EcsService < Base
    def build
      attrs = {
        Type: "AWS::ECS::Service",
        Properties: properties
      }

      attrs[:DependsOn] = depends_on

      attrs
    end

    def depends_on
      return unless vars[:create_elb]
      vars[:create_listener] ? "Listener" : "ListenerSsl"
    end

    def properties
      props = {
        Cluster: @cluster,
        DeploymentConfiguration: deployment_configuration,
        DesiredCount: {
          "Fn::If": [
            "EcsDesiredCountIsBlank",
            {Ref: "AWS::NoValue"},
            {Ref: "EcsDesiredCount"}
          ]
        },
        EnableExecuteCommand: Ufo.config.exec.enabled,
        LoadBalancers: {
          "Fn::If": [
            "CreateTargetGroupIsTrue",
            [
              {
                ContainerName: vars[:container][:name],
                ContainerPort: vars[:container][:port],
                TargetGroupArn: {Ref: "TargetGroup"}
              }
            ],
            {
              "Fn::If": [
                "ElbTargetGroupIsBlank",
                [],
                [
                  {
                    ContainerName: vars[:container][:name],
                    ContainerPort: vars[:container][:port],
                    TargetGroupArn: {Ref: "ElbTargetGroup"}
                  }
                ]
              ]
            }
          ]
        },
        SchedulingStrategy: {Ref: "EcsSchedulingStrategy"}
      }

      props[:TaskDefinition] = vars[:rollback_task_definition] ? vars[:rollback_task_definition] : {Ref: "TaskDefinition"}

      if vars[:container][:network_mode].to_s == 'awsvpc'
        props[:NetworkConfiguration] = {
          AwsvpcConfiguration: {
            Subnets: {Ref: "EcsSubnets"},
            SecurityGroups: security_groups(:ecs)
          }
        }

        if vars[:container][:fargate]
          props[:LaunchType] = "FARGATE"
          props[:NetworkConfiguration][:AwsvpcConfiguration][:AssignPublicIp] = "ENABLED" # Works with fargate but doesnt seem to work with non-fargate
        end
      end

      props
    end

  private
    def deployment_configuration
      ecs = Ufo.config.ecs
      return ecs.configuration if ecs.configuration # provide user full control

      # default
      {
        MaximumPercent: ecs.maximum_percent,
        MinimumHealthyPercent: ecs.minimum_healthy_percent,
      }
    end
  end
end
