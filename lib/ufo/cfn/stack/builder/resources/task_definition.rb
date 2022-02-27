class Ufo::Cfn::Stack::Builder::Resources
  class TaskDefinition < Base
    def build
      return if vars[:rollback_task_definition]

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
      props[:TaskRoleArn] = {"Fn::GetAtt": "TaskRole.Arn"} if IamRoles::TaskRole.build?
      props[:ExecutionRoleArn] = {"Fn::GetAtt": "ExecutionRole.Arn"} if IamRoles::ExecutionRole.build?

      props
    end
  end
end
