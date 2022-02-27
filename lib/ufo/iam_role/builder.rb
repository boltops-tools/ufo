module Ufo::IamRole
  class Builder
    def initialize(role_type)
      @role_type = role_type
    end

    def build
      resource(policies, managed_policy_arns)
    end

    def build?
      !!(policies || managed_policy_arns)
    end

    def policies
      items = Registry.policies[@role_type] # Array of Arrays
      return unless items && !items.empty?

      items.map do |item|
        policy_name, statements = item # first element has policy name, second element has statements
        {
          PolicyName: policy_name,
          PolicyDocument: {
            Version: "2012-10-17",
            Statement: statements
          }
        }
      end
    end

    def managed_policy_arns
      items = Registry.managed_policies[@role_type] # Array of Arrays
      return unless items && !items.empty?

      items.map do |item|
        item.include?('iam::aws:policy') ? item : "arn:aws:iam::aws:policy/#{item}"
      end
    end

    def resource(policies, managed_policy_arns)
      properties = {
        AssumeRolePolicyDocument: {
          Version: "2012-10-17",
          Statement: [
            {
              Effect: "Allow",
              Principal: {
                Service: "ecs-tasks.amazonaws.com"
              },
              Action: "sts:AssumeRole"
            }
          ]
        },
      }
      properties[:Policies] = policies if policies
      properties[:ManagedPolicyArns] = managed_policy_arns if managed_policy_arns

      attrs = {
        Type: "AWS::IAM::Role",
        Properties: properties
      }

      attrs.deep_stringify_keys
    end
  end
end
