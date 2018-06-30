---
title: Load Balancer Support
---

ECS services can be associated with a Load Balancer upon creation. Ufo can automatically create a load balancer.  The options:

1. Create an ELB.
2. Use existing ELB by providing a target group arn.
3. Do not create an ELB.

## Examples

Here are examples of each of them:

    ufo ship demo-web --elb=true

    # Use existing target group from pre-created ELB:
    ufo ship demo-web --elb=arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/target-name/2378947392743

    # Disable creating elb and prompt:
    ufo ship demo-web --elb=false

## ELB Retained

Ufo retains the ELB setting.  So future `ufo ship` commands will not suddenly remove the load balancer.  If you need to change the elb setting, then you can explicitly set a new `--elb` value.

Important: Adding and removing load balancers will change the ELB DNS.  Please take pre-caution using the elb options.

### ELB Types: Application and Network

Ufo supports application and network load balancer types.  To specify the type use `--elb-type`.  Examples:

    ufo ship demo-web --elb-type network
    ufo ship demo-web --elb-type application # default

## ELB Static IP addresses for Network Load Balancers

Network load balancers support static EIP address. You can create a network load balancer using pre-allocated EIP addresses with the the `--elb-eip-ids` option. Example:

    ufo deploy demo-web --elb-eip-ids eipalloc-a8de9ca0 eipalloc-a8de9ca0

If you use the `--elb-eip-ids` option, ufo assumes you want an `--elb-type=network` since only network load balancers support EIPs.

When specifying the `--elb-eip-ids` option, the list length must be the same as the number of subnets configured in your `.ufo/network/settings/default.yml` profile.  The `--elb-eip-ids` setting is optional. If you do not specify it, a network load balancer will still be created you will not have control of the IP addresses.

If you need to change the EIPs for existing services, you might get a "TargetGroup cannot be associated with more than one load balancer" error. To work around this you can set the env variable `UFO_FORCE_TARGET_GROUP=1` which will force a re-creation of the target group.

    UFO_FORCE_TARGET_GROUP=1 ufo deploy demo-web --elb-eip-ids eipalloc-ac226fa4 eipalloc-b5206dbd

To remove the EIPs but still keep the network load balancer, you can specify either:

    UFO_FORCE_TARGET_GROUP=1 ufo deploy demo-web --elb-eip-ids ' '
    UFO_FORCE_TARGET_GROUP=1 ufo deploy demo-web --elb-eip-ids 'empty'

## Conventions

By convention, if the container name is 'web' in the task definition. Deployments of new services will automatically create a load balancer.  The prompt can be bypassed with `--elb=false` for web containers.

    ufo ship demo-web --elb=false

For non-web container the `--elb` option must be explicitly set to `--elb=true` if you want a load balancer to be created.

<a id="prev" class="btn btn-basic" href="{% link _docs/settings.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/params.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
