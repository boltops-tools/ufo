---
title: ufo scale
reference: true
---

## Usage

    ufo scale SERVICE COUNT

## Description

scale the ECS service

Examples:

Scales the service.  Simple wrapper for `aws ecs update-service --service xxx ----desired-count xxx`

    ufo scale hi-web 5


## Options

```
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides ufo/settings.yml.
```

