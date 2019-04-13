---
title: Upgrading to Version 4.4
short_title: Version 4.4
nav_order: 30
order: 1
categories: upgrading
---

In ufo version 4.4, the environment name gets appends to the end of the CloudFormation stack name.  Previous versions prepended the environment name to the stack name. This means a new stack gets created if you're going from version 4.3 to 4.4. For example:

Version | Stack Name
--- | ---
4.3 and below | development-demo-web
4.4 and above | demo-web-development

You must upgrade to using the new stack and delete the old stack manually.  You can delete the old stack with the CloudFormation console by selecting the old stack, clicking Actions, and *Delete Stack*.

## Upgrading Instructions

To upgrade from version 4.3 to 4.4 you can run:

    ufo upgrade v43to44

This updates your `.ufo/settings.yml` file to include `stack_naming: append_env` which removes a warning message when you deploy. Example:

.ufo/settings.yml:

```yaml
base:
  stack_naming: append_env
```

If you would still like to keep the old behavior, you can use `stack_naming: prepend_env` for now. However, support for prepend_env will be removed in future versions.

## Reasoning

CloudFormation names the resources it creates with the beginning portion of the stack name. When the stack name prepends the environment then resources like ELBs a little bit harder to identify since they might be named something like this `product-Elb-K0LFFQ9LK50W`. It makes it harder to distinguish quickly ELBs from different apps created by ufo.

{% include prev_next.md %}