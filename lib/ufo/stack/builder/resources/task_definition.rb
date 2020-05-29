class Ufo::Stack::Builder::Resources
  class TaskDefinition < Base
    def build
      return if @rollback_definition_arn

      {
        Type: "AWS::ECS::TaskDefinition",
        Properties: properties,
        DeletionPolicy: "Retain",
        UpdateReplacePolicy: "Retain",
      }
    end

    def properties
      props = Reconstructor.new(@task_definition).reconstruct

      # Decorate with iam roles if needed
      props[:TaskRoleArn] = {"Fn::GetAtt": "TaskRole.Arn"} if Roles::TaskRole.build?
      props[:ExecutionRoleArn] = {"Fn::GetAtt": "ExecutionRole.Arn"} if Roles::ExecutionRole.build?

      props
    end
  end
end
