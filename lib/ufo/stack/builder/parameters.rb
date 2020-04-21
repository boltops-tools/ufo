class Ufo::Stack::Builder
  class Parameters < Base
    def build
      {
        "Vpc": {
          "Description": "Existing vpc id",
          "Type": "AWS::EC2::VPC::Id"
        },
        "ElbSubnets": {
          "Description": "Existing subnet ids for ELB",
          "Type": "List<AWS::EC2::Subnet::Id>"
        },
        "EcsSubnets": {
          "Description": "Existing subnet ids for ECS",
          "Type": "List<AWS::EC2::Subnet::Id>"
        },
        "ElbTargetGroup": {
          "Description": "Existing target group",
          "Type": "String",
          "Default": ""
        },
        "CreateElb": {
          "Description": "Create elb",
          "Type": "String",
          "Default": true
        },
        "EcsDesiredCount": {
          "Description": "Ecs desired count",
          "Type": "String",
          "Default": 1
        },
        "ElbEipIds": {
          "Description": "ELB EIP Allocation ids to use for network load balancer",
          "Type": "String",
          "Default": ""
        },
        "EcsSchedulingStrategy": {
          "Description": "The scheduling strategy to use for the service",
          "Type": "String",
          "Default": "REPLICA"
        }
      }
    end
  end
end
