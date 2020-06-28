---
title: Settings
nav_order: 12
---

The behavior of ufo can be configured with a `settings.yml` file.  A starter project `.ufo/settings.yml` file is generated as part of the `ufo init` command. There are can be multiple settings files. The options from the files get merged and respected in the following precedence:

1. current folder - The current folder's `.ufo/settings.yml` values take the highest precedence.
2. user - The user's `~/.ufo/settings.yml` values take the second highest precedence.
3. default - The [default settings](https://github.com/tongueroo/ufo/blob/master/lib/ufo/default/settings.yml) bundled with the tool takes the lowest precedence.

Let's take a look at an example `settings.yml`:

```yaml
base:
  image: tongueroo/demo-ufo
  # clean_keep: 30 # cleans up docker images on your docker server.
  # ecr_keep: 30 # cleans up images on ECR and keeps this remaining amount. Defaults to keep all.
  # network_profile: default # .ufo/settings/network/default.yml file
  # cfn_profile: default # .ufo/settings/cfn/default.yml file

development:
  # cluster: dev # uncomment if you want the cluster name be other than the default
                 # the default is to match UFO_ENV.  So UFO_ENV=development means the ECS
                 # cluster will be name development
  # The aws_profile tightly binds UFO_ENV to AWS_PROFILE and vice-versa.
  # aws_profile: dev_profile

production:
  # cluster: prod
  # aws_profile: prod_profile
```

The table below covers each setting:

Setting  | Description
------------- | -------------
aws_profile  | If you have the `AWS_PROFILE` environment variable set, this will ensure that you are deploying the right `UFO_ENV` to the right AWS environment. It is explained below.
cfn_profile | The name of the cfn profile settings file to use. Maps to .ufo/settings/cfn/NAME.yml file. Will match an `UFO_ENV` file if it exists. IE: .ufo/settings/cfn/development.yml. Otherwise it defaults to .ufo/settings/cfn/default.yml.
clean_keep  | Docker images generated from ufo are cleaned up automatically for you at the end of `ufo ship`. This controls how many docker images to keep around. The default is 3.
cluster  | By convention, the ECS cluster that ufo deploys to matches the `UFO_ENV`. If `UFO=development`, then `ufo ship` deploys to the `development` ECS cluster. This is option overrides this convention.
ecr_keep  | If you are using AWS ECR, then the ECR images can also be automatically cleaned up at the end of `ufo ship`. By default this is set to `nil` and all AWS ECR are kept.
image  | The `image` value is the name that ufo will use for the Docker image name to be built.  Only provide the basename part of the image name without the tag because ufo automatically generates the tag for you. For example, `tongueroo/demo-ufo` is correct and `tongueroo/demo-ufo:my-tag` is incorrect.
managed\_security\_groups | Create managed security groups for application ELBs. Defaults to true. If you disable it with false then no managed security groups will be created by UFO.
network_profile | The name of the network profile settings file to use. Maps to .ufo/settings/network/NAME.yml file. Will match an `UFO_ENV` file if it exists. IE: .ufo/settings/network/development.yml. Otherwise it defaults to .ufo/settings/network/default.yml.

## AWS_PROFILE support

An interesting option is `aws_profile`.  This allows you to tightly connect an AWS_PROFILE to a UFO_ENV. The details are in the [Settings AWS_PROFILE docs]({% link _docs/settings/aws_profile.md %}).

## ECS Cluster Convention

Normally, the ECS cluster defaults to whatever UFO_ENV is set to by [convention]({% link _docs/conventions.md %}).  For example, when `UFO_ENV=production` the ECS Cluster is `production` and when `UFO_ENV=development` the ECS Cluster is `development`.  There are several ways to override this behavior. This is detailed in the [Settings Cluster docs]({% link _docs/settings/cluster.md %}).

{% include prev_next.md %}
