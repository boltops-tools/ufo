---
title: Minimal Deploy IAM Policy
nav_order: 29
---

Note, the `/tmp/ecs-deploy-policy.json` policy is available at [Minimal Deploy IAM]({% link _docs/extras/minimal-deploy-iam.md %}).

## Existing IAM Role

If you're using CodeBuild with `ufo ship` to handle deployments, you can use the same policy for the role that you assign to the the CodeBuild project and attach it to the the CodeBuild service IAM role that is usually created with the CodeBuild Console wizard.  For example, of the IAM role was called `codebuild-myapp-service-role`:

    aws iam put-role-policy --role-name codebuild-myapp-service-role --policy-name EcsDeployPolicy --policy-document file:///tmp/ecs-deploy-policy.json
    aws iam get-role-policy --role-name codebuild-myapp-service-role --policy-name EcsDeployPolicy

The `put-role-policy` command adds a *inline* policy to the existing IAM role.

## New IAM Role

If you are creating the IAM role for CodeBuild yourself from scratch these commands will be helpful:

Create the policy document:

    cat << 'EOF' > /tmp/role-trust-policy.json
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "codebuild.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }]
    }
    EOF

Create the IAM resources:

  aws iam create-role --role-name EcsDeployRole --assume-role-policy-document file:///tmp/role-trust-policy.json
  aws iam create-policy --policy-name EcsDeployPolicy --policy-document file:///tmp/ecs-deploy-policy.json
  ACCOUNT=$(aws sts get-caller-identity | jq -r '.Account')
  aws iam attach-role-policy --policy-arn arn:aws:iam::$ACCOUNT:policy/EcsDeployPolicy --role-name EcsDeployRole

The `attach-role-policy` command attaches a Customer Managed IAM policy to the IAM role. This is a little more reusable than using an inline policy.

{% include prev_next.md %}