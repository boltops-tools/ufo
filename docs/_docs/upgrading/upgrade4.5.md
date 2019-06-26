---
title: Upgrading to Version 4.5
short_title: Version 4.5
order: 1
categories: upgrading
nav_order: 34
---

In ufo version 4.4 and 4.5, the default cloudformation stack names used by ufo were changed.

* In versions 4.3 and below, the cluster name is prepended to the service name.
* In version 4.4, the cluster name is appended to the service name.
* In version 4.5, the Ufo.env name is appended to the service name.

By convention, the cluster name defaults to UFO_ENV. So, by default there is not difference between cluster name and UFO_ENV.  However, if you were using the cluster option then there will be a difference.  Here's a table to help explain:

Version | UFO_ENV | Cluster Name | Stack Name
--- | --- | --- | ---
4.3 and below | development | mycluster | mycluster-demo-web
4.4 | development | mycluster | demo-web-mycluster
4.5 | development | mycluster | demo-web-development

You must upgrade to using the new stack and delete the old stack manually.  You can delete the old stack with the CloudFormation console by selecting the old stack, clicking Actions, and *Delete Stack*.

## Upgrading Instructions

To upgrade from version 4.3 to 4.5 you can run:

    ufo upgrade v43to45

This updates your `.ufo/settings.yml` file to include `stack_naming: append_ufo_env` which removes a warning message and 20 second delay when you deploy. Example:

.ufo/settings.yml:

```yaml
base:
  stack_naming: append_ufo_env
```

If you would still like to keep the old behavior, you can use:

Version | Setting
--- | ---
4.3 and below | stack_naming: prepend_cluster
4.4 | stack_naming: append_cluster
4.5 | stack_naming: append_ufo_env

## Reasoning

CloudFormation names the resources it creates with the beginning portion of the stack name. When the stack name prepends the environment then resources like ELBs a little bit harder to identify since they might be named something like this `product-Elb-K0LFFQ9LK50W`. It makes it harder to distinguish ELBs from different apps created by ufo.

{% include prev_next.md %}