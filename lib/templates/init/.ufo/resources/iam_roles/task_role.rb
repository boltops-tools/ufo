# Example starter execution role.
# IAM Role permissions that the ECS Task or container needs.
#
# Docs: https://ufoships.com/docs/intro/task-iam/
#
# For `ufo exec` of `aws ecs execute-command`
# See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html#ecs-exec-enabling-and-using
iam_policy("EcsExecuteCommand",
  Action: [
    "ssmmessages:CreateControlChannel",
    "ssmmessages:CreateDataChannel",
    "ssmmessages:OpenControlChannel",
    "ssmmessages:OpenDataChannel",
  ],
  Effect: "Allow",
  Resource: "*",
)

# Managed policies examples:
# managed_iam_policy("AmazonSSMReadOnlyAccess")
