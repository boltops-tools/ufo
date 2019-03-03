---
title: Create ecsTaskExecutionRole with AWS CLI
---

Here are commands you can copy and paste to create the `ecsTaskExecutionRole` IAM role:

    cat > /tmp/task-execution-assume-role.json <<EOL
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
            "Service": "ecs-tasks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
    EOL
    aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document file:///tmp/task-execution-assume-role.json
    aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

This is based from [Tutorial: Creating a Cluster with a Fargate Task Using the Amazon ECS CLI](https://docs.amazonaws.cn/en_us/AmazonECS/latest/userguide/ecs-cli-tutorial-fargate.html).

Also for a tutorial on how to create this `ecsTaskExecutionRole` via the AWS IAM Console: [Amazon ECS Task Execution IAM Role
](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html).