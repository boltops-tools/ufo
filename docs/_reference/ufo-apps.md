---
title: ufo apps
reference: true
---

## Usage

    ufo apps

## Description

List apps.

This command lists ECS services for an ECS cluster. It includes ECS services that were not created by ufo also.

## Examples

    $ ufo apps
    Listing ECS services in the dev cluster.
    +-------------------------------------+-----------------+---------+-------------+-----+------+
    |            Service Name             | Task Definition | Running | Launch type | Dns | Ufo? |
    +-------------------------------------+-----------------+---------+-------------+-----+------+
    | dev-hi-web-Ecs-3JCJA3QFYK1 (hi-web) | hi-web:286      | 8       | EC2         |     | yes  |
    +-------------------------------------+-----------------+---------+-------------+-----+------+


## Options

```
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides .ufo/settings.yml.
```

