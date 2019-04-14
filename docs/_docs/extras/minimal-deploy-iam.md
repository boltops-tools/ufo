---
title: Minimal Deploy IAM Policy
nav_order: 28
---

The IAM user you use to run the `ufo ship` command needs a minimal set of IAM policies in order to deploy to ECS. Here is a table of the baseline services needed:

Service | Description
--- | ---
CloudFormation | To create the CloudFormation stack that then creates the most of the AWS resources that Ufo creates like ECS service and the ELB.
EC2 | To describe subnets associated with VPC. Used to configured subnets to use for ECS tasks and ELBs.
ECR | To pull and push to the ECR registry.  If you're using DockerHub this permission is not required.
ECS | To create ECS service, task definitions, etc.
ElasticloadBalancing | To create the ELB and related load balancing resoures like Listeners and Target Groups.
ElasticloadBalancingV2 | To create the ELB and related load balancing resoures like Listeners and Target Groups.
Logs | To write to CloudWatch Logs.
Route53 | To create vanity DNS endpoint when using [Route53 setting]({% link _docs/extras/route53-support.md %}).

## Instructions

It is recommended that you create an IAM group and associate it with the IAM users that need access to use `jets deploy`.  Here are starter instructions and a policy that you can tailor for your needs:

### Commands Summary

Here's a summary of the commands:

aws iam create-group --group-name Ufo
cat << 'EOF' > /tmp/ecs-deploy-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudformation:*",
                "ec2:*",
                "ecr:*",
                "ecs:*",
                "elasticloadbalancing:*",
                "elasticloadbalancingv2:*",
                "logs:*",
                "route53:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": [
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF
aws iam put-group-policy --group-name Ufo --policy-name UfoPolicy --policy-document file:///tmp/ecs-deploy-policy.json

Then create a user and add the user to IAM group. Here's an example:

    aws iam create-user --user-name tung
    aws iam add-user-to-group --user-name tung --group-name Ufo

## CodeBuild

If you're using CodeBuild with `ufo ship` to handle deployments, you can use the same policy for the role that you assign to the the CodeBuild project and attach it to the the CodeBuild service IAM role that is usually created with the CodeBuild Console wizard.  For example, of the IAM role was called `codebuild-myapp-service-role`:

    aws iam put-role-policy --role-name codebuild-myapp-service-role --policy-name EcsDeployPolicy --policy-document file:///tmp/ecs-deploy-policy.json
    aws iam get-role-policy --role-name codebuild-myapp-service-role --policy-name EcsDeployPolicy

## ECS Task IAM Policy vs User Deploy IAM Policy

This page refers to your **user** IAM policy used when running `ufo ship`. These are different from the IAM Policies associated with ECS Task.  For those iam policies refer to [IAM Roles for Tasks
](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html).

{% include prev_next.md %}