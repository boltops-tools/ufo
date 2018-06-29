---
title: CloudFormation Stack
---

Under the hood, ufo creates most of the required resources with a CloudFormation stack.  This includes the ELB, Target Group, Listener, Security Groups, ECS Service, Route 53 records.

## CloudFormation Stack Name

The CloudFormation stack name is based on the cluster, service name and UFO_ENV_EXTRA.  A few examples help demonstrate:

Command | Stack Name
--- | ---
ufo ship demo-web | development-demo-web
ufo ship demo-web --cluster dev | dev-demo-web
UFO_ENV_EXTRA=2 ufo ship demo-web --cluster dev | dev-demo-web-2

## CloudFormation Stack Source Code

The CloudFormation stack is currently generated from a template. The source code for this template is located at [lib/cfn/stack.yml](https://github.com/tongueroo/ufo/blob/master/lib/cfn/stack.yml).

## Customizing CloudFormation Resources

One important thing to point out is the `custom_properties` calls in the template. The custom_properties takes configurations from `.ufo/settings/network/[profile].yml` and injects them into the CloudFormation template.  This allows you to customize the CloudFormation resource properties in the CloudFormation template.

More info on how to customize is available at:

* [Settings Network]({% link _docs/settings-network.md %})
