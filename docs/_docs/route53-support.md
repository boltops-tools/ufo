---
title: Route53 Support
---

Ufo can automatically create a "pretty" route53 record an set it to the created ELB dns name. This is done in by configuring the `.ufo/settings/network/[profile].yml` file. Example `.ufo/settings/network/default.yml`:

```yaml
dns:
  name: "{stack_name}.mydomain.com."
  hosted_zone_name: mydomain.com. # dont forget the trailing period
```

The `{stack_name}` variable gets substituted with the CloudFormation stack name launched by ufo. So for example:

    ufo ship demo-web

Results in this:

    "{stack_name}.mydomain.com." => "development-demo-web.mydomain.com."

**IMPORTANT**: The route53 host zone must already exist. You can create route53 hosted zone with the cli like so:

    aws route53 create-hosted-zone --name mydomain.com --caller-reference $(date +%s)
    aws route53 list-hosted-zones

<a id="prev" class="btn btn-basic" href="{% link _docs/params.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/variables.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
