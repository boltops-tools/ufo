# Example starter execution role.
# IAM Role permissions that EC2 Instance or host needs.
#
# Docs: https://ufoships.com/docs/iam-roles/
#
# Starter IAM permissions for secrets, ssm, and minimal ecr and cloudwatch permissions
iam_policy("SsmParameterStore",
  Action: [
    "ssm:GetParameters",
  ],
  Effect: "Allow",
  Resource: "*"
)
iam_policy("SecretsManager",
  Action: [
    "secretsmanager:GetSecretValue",
  ],
  Effect: "Allow",
  Resource: "*"
)
# AmazonECSTaskExecutionRolePolicy includes use cases. Minimal ecr and logs permissions.
# See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
managed_iam_policy("service-role/AmazonECSTaskExecutionRolePolicy")
