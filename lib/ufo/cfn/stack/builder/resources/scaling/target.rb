module Ufo::Cfn::Stack::Builder::Resources::Scaling
  class Target < Base
    def build
      return unless autoscaling_enabled?

      text =<<~EOL
        Type: AWS::ApplicationAutoScaling::ScalableTarget
        DependsOn: EcsService
        Properties:
          RoleARN: !GetAtt ScalingRole.Arn
          ResourceId: !Join
            - "/"
            - [service, #{@cluster}, !GetAtt [EcsService, Name]]
          ServiceNamespace: ecs
          ScalableDimension: ecs:service:DesiredCount
          MinCapacity: #{autoscaling.min_capacity}
          MaxCapacity: #{autoscaling.max_capacity}
      EOL
      Ufo::Yaml.load(text).deep_symbolize_keys
    end
  end
end
