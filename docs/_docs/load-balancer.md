---
title: Load Balancer Support
---

ECS services can be associated with a Load Balancer upon creation. Ufo can automatically create a load balancer.  The options:

1. Automatically create the ELB.
2. Provide a target group from an existing ELB.
3. No ELB is created.

## Examples

Here are examples for each of them:

    ufo ship hi-web --elb=true

    # Use existing target group from pre-created ELB:
    ufo ship hi-web --elb=arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/target-name/2378947392743
    ufo ship hi-web --target-group=arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/target-name/2378947392743 # legacy, currently works

    # Disable creating elb and prompt:
    ufo ship hi-web --elb=false

Important: whenever the `--elb` value is explicitly set and changed, the load balancer gets replaced and the dns record will be **different**.

## ELB Retained

Ufo works to retain the ELB setting.  So future `ufo ship` commands will not suddenly remove the load balancer.  If you need to change the elb setting, then you can explicitly set a new `--elb` value.

Important: When adding and removing load balancers also results in the dns changing.  This is why ufo retains the elb setting by default. Please take pre-caution using the elb options.

### ELB Types: Application and Network

Ufo supports application and network load balancer types.  To specify the type use `--elb-type`.  Examples:

    ufo ship hi-web --elb-type network
    ufo ship hi-web --elb-type application # default

## ELB Static IP addresses for Network Load Balancers

Network load balancers support static EIP address. You can create a network load balancer pre-allocated EIP address with the the `--elb-eip-ids` option. Example:

    ufo deploy hi-web --elb-eip-ids eipalloc-a8de9ca0 eipalloc-a8de9ca0

When specifying the `--elb-eip-ids` option, the list must be the same length as the number of subnets configured in your `.ufo/network/settings/*.yml` profile.  The `--elb-eip-ids` setting is optional. If you do not specify it, a network load balancer wil be created with IP addresses, but will change if you ever delete the load balancer.

If you need to change the EIPs for existing services, you'll get a "TargetGroup cannot be associated with more than one load balancer" error. To work around this you can set the  `UFO_FORCE_TARGET_GROUP` env variable which will force a re-creation of the target group.

    UFO_FORCE_TARGET_GROUP=1 ufo deploy hi-web --elb-eip-ids eipalloc-ac226fa4 eipalloc-b5206dbd

To remove the EIPs but still keep the network load balancer, you can specify either:

    UFO_FORCE_TARGET_GROUP=1 ufo deploy hi-web --elb-eip-ids ' '
    UFO_FORCE_TARGET_GROUP=1 ufo deploy hi-web --elb-eip-ids 'empty'

## Conventions

By convention, if the container name is 'web' in the task definition. If the ECS service does not yet exist, the deploy automatically create a load balancer.  The prompt can be bypassed with `--elb=false` for web containers.

    ufo ship hi-web --elb=false

For non-web container the `--elb` option must be explicitly set to `--elb=true` if you want a load balancer to be created.

<a id="prev" class="btn btn-basic" href="{% link _docs/settings.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/params.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
