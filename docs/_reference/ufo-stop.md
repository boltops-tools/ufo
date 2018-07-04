---
title: ufo stop
reference: true
---

## Usage

    ufo stop SERVICE

## Description

Stop tasks from old deployments.  Can speed up deployments with network load balancer.

ECS deployments can sometimes take a while. One reason could be because the old ECS tasks can take some time to drain and removed. The recommended way to speed this draining process up is configuring the `deregistration_delay.timeout_seconds` to a low value.  You can configured this in `.ufo/settings/cfn/default.yml`. For more info refer to http://ufoships.com/docs/settings-cfn/  This setting works well for Application Load Balancers.

However, for Network Load Balancers, it seems like the deregistration_delay is not currently being respected. In this case, it take an annoying load time and this command can help speed up the process.

The command looks for any extra old ongoing deployments and stops the tasks associated with them.  This can cause errors for any inflight requests.

    ufo stop demo-web


## Options

```
[--verbose], [--no-verbose]
[--mute], [--no-mute]
[--noop], [--no-noop]
[--cluster=CLUSTER]          # Cluster.  Overrides .ufo/settings.yml.
```

