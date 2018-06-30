---
title: Customize CloudFormation
---

Under the hood, ufo creates most of the required resources with a CloudFormation stack.  This includes the ELB, Target Group, Listener, Security Groups, ECS Service, and Route 53 records.  You might need to customize these resources.  Here are the ways to customize the resources that ufo creates.

1. Settings - This is done with the `.ufo/settings/cfn/default.yml` file. This is the main and recommended way to customize.
2. Override cfn template - You can specify your own template to use.  You save this template at `.ufo/settings/cfn/stack.yml`. Use this approach as a last resort only when necessary.

## Settings

The recommended to customize the CloudFormation resources is by adding properties to `.ufo/settings/cfn/default.yml`.  More info here: [Settings Cfn]({% link _docs/settings-cfn.md %})

## Override Cfn Template

You can override the source template that ufo uses by creating your own and saving it at `.ufo/settings/cfn/stack.yml` in your project. It is recommended that you copy the source code and work from there [cfn/stack.yml](https://github.com/tongueroo/ufo/blob/master/lib/cfn/stack.yml).  Use this approach as a last resort only when absolutely necessary as it'll likely break with a future version of ufo.

## CloudFormation Stack Name

The CloudFormation stack name is based on the cluster, service name and UFO_ENV_EXTRA.  A few examples help demonstrate:

Command | Stack Name
--- | ---
ufo ship demo-web | development-demo-web
ufo ship demo-web --cluster dev | dev-demo-web
UFO_ENV_EXTRA=2 ufo ship demo-web --cluster dev | development-demo-web-2

## CloudFormation Stack Source Code

The CloudFormation stack is currently generated from a template. The source code for this template is located at [cfn/stack.yml](https://github.com/tongueroo/ufo/blob/master/lib/cfn/stack.yml).  This implementation might change in the future.


