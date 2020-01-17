---
title: Settings Network
short_title: Network
categories: settings
nav_order: 16
---

The settings.yml file references a network settings file with the `network_profile` option. This file has configurations that are related to the network.  The source code for the starter template file is at [network/default.yml.tt](https://github.com/tongueroo/ufo/blob/master/lib/template/.ufo/settings/network/default.yml.tt)  Here's an example network settings file.

```
---
vpc: vpc-11111111
ecs_subnets: # at least 2 subnets required
  - subnet-11111111
  - subnet-22222222
elb_subnets: # defaults to same subnets as ecs_subnets when not set
  - subnet-33333333
  - subnet-44444444

# Optional existing security group ids to add in addition to the ones created by ufo.
# elb_security_groups:
#   - sg-aaa
# ecs_security_groups:
#   - sg-bbb
```

Option | Description
--- | ---
vpc | Used to create ecs and elb security groups, target group in the CloudFormation template.
ecs_subnets | Used to assign a subnet mapping to the ECS service created in CloudFormation when the network mode is awsvpc. Also used to in .ufo/params.yml as part of the run_task api call that is made by `ufo task`.
elb_subnets | Used to create elb load balancer.  Defaults to same subnets as ecs_subnets when not set.
ecs_security_groups | Additional security groups to associate with the ECS tasks.
elb_security_groups | Additional security groups to associate with the ELB.

{% include prev_next.md %}
