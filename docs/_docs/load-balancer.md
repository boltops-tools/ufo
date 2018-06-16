---
title: Load Balancer Support
---

ECS services can be associated with a Load Balancer upon creation. Ufo can automatically create a load balancer.  The options:

1. Automatically create the ELB.
2. Provide a target group from an existing ELB.
3. No ELB is created and associated.

## Examples

Here are examples for each of them:

    # Use different profiles to create the ELB:
    #  .ufo/balancer/profiles/default.yml
    #  .ufo/balancer/profiles/production.yml
    ufo ship hi-web --elb=default
    ufo ship hi-web --elb=production

    # Use existing target group from pre-created ELB:
    ufo ship hi-web --elb=arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/target-name/2378947392743
    ufo ship hi-web --target-group=arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/target-name/2378947392743 # legacy, currently works

    # Disable creating elb and prompt:
    ufo ship hi-web --elb=false

## Balancer Profiles

Underneath the hood, ufo uses the [balancer](https://github.com/tongueroo/balancer) gem, to create the load balancer.  Balancer uses profile files. The `ufo init` generates initial default `.ufo/balancer/profiles/default.yml` and `.ufo/settings.yml` files.  Edit these files and configure it to your needs. You can regenerate the `default.yml` profile file with `ufo balancer init`. Example:

    ufo balancer init --subnets subnet-aaa subnet-bbb --vpc-id vpc-123
    ufo balancer init # use default vpc and subnet network settings

## Settings

You can override the `balance_profile` in the `.ufo/settings.yml` file to use profile files other than the `default.yml`.

```yaml
development:
  balancer_profile: default

production:
  balancer_profile: production
```

## Load Balancer Conventions

By convention, if the container name is 'web' in the task definition. If the ECS service does not yet exist, the deploy will prompt you for the ELB target group. This is also covered a in the [Conventions]({% link _docs/conventions.md %}) page.  Otherwise, you must specify the `--elb` option to create an ELB.

For non-web container the `--elb` option gets ignored.  The prompt can be bypassed with `--elb=false` for web containers.

    ufo ship hi-web --elb=false

Or if you would like to specify the target-group in a non-prompt mode you can use the `--elb` option to bypass the prompt.

    ufo ship hi-web --elb=arn:aws:elasticloadbalancing:us-east-1:12345689:targetgroup/hi-web/12345

<a id="prev" class="btn btn-basic" href="{% link _docs/settings.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/params.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
