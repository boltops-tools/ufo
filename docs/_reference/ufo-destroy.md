---
title: ufo destroy
reference: true
---

## Usage

    ufo destroy SERVICE

## Description

Destroy the ECS service.

## Examples

Ufo provides a quick way to destroy an ECS service. This is effectively the same thing as deleting the CloudFormation stack.

    ufo destroy demo-web

If you would like to bypass the prompt, you can use the `--sure` option.

    ufo destroy demo-web --sure


## Options

```
[--sure], [--no-sure]        # By pass are you sure prompt.
[--wait], [--no-wait]        # Wait for completion
                             # Default: true
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides .ufo/settings.yml.
```

