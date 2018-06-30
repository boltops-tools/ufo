---
title: ufo scale
reference: true
---

## Usage

    ufo scale SERVICE COUNT

## Description

Scale the ECS service.

Ufo provides a command to scale up and down an ECS service quickly. It is a simple wrapper for `aws ecs update-service --service xxx ----desired-count xxx`.  Here's an example of how you use it:

    $ ufo scale demo-web 3
    Scale demo-web service in stag cluster to 3

While scaling via this method is quick and convenient the [ECS Service AutoScaling](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html) that is built into ECS is a much more powerful way to manage scaling your ECS service.


## Options

```
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides .ufo/settings.yml.
```

