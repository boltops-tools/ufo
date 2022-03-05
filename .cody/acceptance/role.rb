iam_policy(
  "application-autoscaling",
  "cloudformation",
  "ec2",
  "ecr",
  "ecs",
  "elasticloadbalancing",
  "elasticloadbalancingv2",
  "iam", # to create .ufo/resources/iam_roles
  "logs",
  "route53",
  "ssm", # for codebuild to pull in ssm parameter
)

iam_policy(
  Action: [
    "iam:PassRole",
  ],
  Effect: "Allow",
  Resource: "*",
  Condition: {
    StringLike: {
      "iam:PassedToService": [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
)
