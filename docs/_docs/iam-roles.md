---
title: Task Definition IAM Roles
nav_order: 21
---

## What are ECS IAM Roles?

For ECS Task Definitions, you can assign it 2 IAM roles: 1) taskRoleArn and 2) executionRoleArn. It's usually defined in the JSON structure like so:

```json
{
  "family": "..",
  "taskRoleArn": "...",
  "executionRoleArn": "...",
  "containerDefinitions": [
    ...
  ]
}
```

Here's a table that explains the difference between the 2 IAM roles.

Name | Purpose
--- | ---
taskRoleArn | This is the role that the ECS task itself uses. So this is what IAM permissions your application has access to. Think about it as the "container role".
executionRoleArn | This is the role that the EC2 instance host uses. This allows the EC2 instance to pull from the ECR registry. Think about it as the "host role".

## How to Assign IAM Roles with UFO

You can assign an IAM role to the ECS Task definition in ways:

1. IAM Role with Code (UFO Managed)
2. Precreated IAM Role

## IAM Role with Code (UFO Managed)

UFO can automatically create the IAM and assign it to the task definition. You create these files so UFO will know to create and manage the IAM roles.

    .ufo/iam_roles/execution_role.rb
    .ufo/iam_roles/task_role.rb

### Example 1

You then use a DSL to create the IAM roles. Here are examples:

.ufo/iam_roles/execution_role.rb

```ruby
managed_iam_policy("AmazonSSMReadOnlyAccess")
managed_iam_policy("SecretsManagerReadWrite")
managed_iam_policy("service-role/AmazonECSTaskExecutionRolePolicy")
```

.ufo/iam_roles/task_role.rb

```ruby
iam_policy("AmazonS3ReadOnlyAccess",
  Action: [
    "s3:Get*",
    "s3:List*"
  ],
  Effect: "Allow",
  Resource: "*"
)
iam_policy("CloudwatchWrite",
  Action: [
    "cloudwatch:PutMetricData",
  ],
  Effect: "Allow",
  Resource: "*"
)
```

### Example 2

You can use the `managed_iam_policy` and `iam_policy` together. You can also group multiple statements in the `iam_policy` declaration.

.ufo/iam_roles/task_role.rb

```ruby
managed_iam_policy("AmazonSSMManagedInstanceCore")

iam_policy("custom-policy", [
  {
    Action: "ecs:UpdateContainerInstancesState",
    Resource: "*",
    Effect: "Allow"
  },
  {
    Action: "sns:Publish",
    Resource: "*",
    Effect: "Allow"
  }
])
```

## Pre-Created IAM Role

You can also assign the task definition `executionRoleArn` with pre-created IAM roles. It looks something like this in the `.ufo/templates/main.json.erb` file:

```json
{
  "family": "<%= @family %>",
  "taskRoleArn": "arn:aws:iam::112233445566:role/pre-created-iam-role",
  "executionRoleArn": "arn:aws:iam::112233445566:role/pre-created-iam-role",
  "containerDefinitions": [
    ...
  ]
}
```

{% include prev_next.md %}
