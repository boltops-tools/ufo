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
          MinCapacity: #{min_capacity}
          MaxCapacity: #{max_capacity}
      EOL
      Ufo::Yaml.load(text).deep_symbolize_keys
    end

  private
    def min_capacity
      return autoscaling.min_capacity if vars[:new_stack] && !autoscaling.manual_changes.retain
      scalable_target ? scalable_target.min_capacity : autoscaling.min_capacity
    end

    def max_capacity
      return autoscaling.max_capacity if vars[:new_stack] && !autoscaling.manual_changes.retain
      scalable_target ? scalable_target.max_capacity : autoscaling.max_capacity
    end

    def scalable_target
      resources = stack_resources(vars[:stack_name])
      return unless resources
      ecs_service = resources.find { |r| r.logical_resource_id == "EcsService" }
      service_name = File.basename(ecs_service.physical_resource_id) # IE: demo-web-dev-EcsService-Tw0nPMgpkmm4
      resource_id = "service/#{vars[:cluster]}/#{service_name}"
      resp = applicationautoscaling.describe_scalable_targets(
        service_namespace: "ecs",
        resource_ids: [resource_id],
      )
      resp.scalable_targets.first
    end
    memoize :scalable_target
  end
end
