The properties in the file `.ufo/settings/cfn/default.yml` map directly to ufo's CloudFormation resources. It allows you to customize the resources.  The keys get transform to CamelCase keys to work with the CloudFormation template.

### Example of Customization

Let's customize the `AWS::ElasticLoadBalancingV2::TargetGroup` resource created by CloudFormation.  We'll adjust the `deregistration_delay.timeout_seconds` to `8`.  Here's the relevant section of the `.ufo/settings/cfn/default.yml`

```
TargetGroup:
...
  TargetGroupAttributes:
  - Key: deregistration_delay.timeout_seconds
    Value: 8
```

The value will be injected to the generated CloudFormation template under the corresponding "TargetGroup Properties".  The generated template looks something like this:

```
TargetGroup:
  Properties:
...
    TargetGroupAttributes:
    - Key: deregistration_delay.timeout_seconds
      Value: 8
...
```

In this way, you can customize and override any properties associated with resources created by the ufo CloudFormation stack.

Here's a list of the resources in the [cfn/stack.yml](https://github.com/tongueroo/ufo/blob/master/lib/cfn/stack.yml) that you can customize:

* Ecs
* EcsSecurityGroup
* EcsSecurityGroupRule
* Elb
* ElbSecurityGroup
* Listener
* TargetGroup

## Layering Support

The `base.yml` profile files always get evaluated and env-specific ENV.yml file are layered or merged together. This miminizes duplication.  For example, these files are merged:

* .ufo/settings/cfn/base.yml
* .ufo/settings/cfn/development.yml

The settings in `development.yml` override the settings in `base.yml`. Here's another example:

* .ufo/settings/network/base.yml
* .ufo/settings/network/development.yml

Note, this feature is available in v5.0.4+.

For the most up to date list check out the [cfn/stack.yml](https://github.com/tongueroo/ufo/blob/master/lib/cfn/stack.yml) source code directly.
