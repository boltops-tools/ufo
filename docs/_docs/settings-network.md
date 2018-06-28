---
title: Settings Network
---

The settings.yml file references a network settings file. A `.ufo/settings/network/default.yml` is generated for when you run `ufo init`.  This file generally has configurations that are more related to network components.  The source code for the starter template file is at (lib/template/.ufo/settings/network/default.yml.tt)[https://github.com/tongueroo/ufo/blob/master/lib/template/.ufo/settings/network/default.yml.tt]  Here's an example of a network settings file.

```
---
subnets: # at least 2 subnets required
  - subnet-77d3bf3d
  - subnet-b0c0298e
vpc: vpc-a6f716dc

# Optional additional existing security group ids to add on top of the ones created
# by ufo.
# elb_security_groups:
#   - sg-aaa
# ecs_security_groups:
#   - sg-bbb

elb:
  scheme: internet-facing

target_group:
  port: 80 # not needed with ECS
  target_group_attributes:
  - key: deregistration_delay.timeout_seconds
    value: 1
listener:
  port: 80 # required by ufo, used in cloudformation template

dns:
  name: "{stack_name}.stag.boltops.com."
  hosted_zone_name: stag.boltops.com. # dont forget the trailing period
```

The subnets and vpc configs are used for network components like the ELB and subnets is used for ECS tasks.

## Customizing Resources

Some of the properties in this file map directly to CloudFormation resources and allows you to customize the resources.  The settings properties will transform the underscore keys to CamelCase keys which CloudFormation works with.  Notice the `target_group_attributes` property above.

```
target_group:
...
  target_group_attributes:
  - key: deregistration_delay.timeout_seconds
    value: 1
```

That effectively will inject this code into the CloudFormation template and allows you to customize the resource properties for the TargetGroup.

```
  TargetGroupAttributes:
  - Key: deregistration_delay.timeout_seconds
    Value: 1
```

<a id="prev" class="btn btn-basic" href="{% link _docs/params.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/variables.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
