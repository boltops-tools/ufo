---
title: ufo destroy
reference: true
---

## Usage

    ufo destroy SERVICE

## Description

destroys the ECS service

Examples:

Destroys the service.  It will automatcally set the desired task size to 0 and stop all task so the destory happens in one command.

    ufo destroy hi-web


## Options

```
[--sure], [--no-sure]        # By pass are you sure prompt.
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides ufo/settings.yml.
```

