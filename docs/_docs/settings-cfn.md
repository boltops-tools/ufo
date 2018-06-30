---
title: Settings Cfn
---

## Customizing Resources

The properties in the file `.ufo/settings/cfn/default.yml` map directly to ufo's CloudFormation resources. It allows you to customize the resources.  The keys get transform to CamelCase keys to work with the CloudFormation template.

## Example of Customization

Let's customize the `AWS::ElasticLoadBalancingV2::TargetGroup` resource created by CloudFormation.  We'll adjust the `deregistration_delay.timeout_seconds` to `8`.  Here's the relevant section of the `.ufo/settings/cfn/default.yml`

```
target_group:
...
  target_group_attributes:
  - key: deregistration_delay.timeout_seconds
    value: 8
```

The value will be injected to the generated CloudFormation template under the corresponding "TargetGroup Properties".  The generated template looks something like this:

```
TargetGroup:
  Properties:
...
    TargetGroupAttributes:
    - Key: deregistration_delay.timeout_seconds
      Value: 8
..
```

In this way, you can customize and override any property associated with any resource created the ufo CloudFormation stack.

Here's a list of the resources in the [cfn/stack.yml](https://github.com/tongueroo/ufo/blob/master/lib/cfn/stack.yml) that you can customize:

* Dns
* Ecs
* EcsCrossSecurityGroupRule
* EcsSecurityGroup
* Elb
* ElbSecurityGroup
* Listener
* TargetGroup

For the most up to date list check out the [cfn/stack.yml](https://github.com/tongueroo/ufo/blob/master/lib/cfn/stack.yml) source code directly.

<a id="prev" class="btn btn-basic" href="{% link _docs/settings-network.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/params.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>