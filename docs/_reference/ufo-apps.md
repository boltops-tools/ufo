---
title: ufo apps
reference: true
---

## Usage

    ufo apps

## Description

List apps.

This command lists ECS services for an ECS cluster. It includes ECS services that were not created by ufo also.  A `Ufo?` column value of `yes` indicates that the ECS service was created by ufo version 4 and above.  If the service was created with ufo version 3 and below then it will show up as `no`.

## Examples

    $ ufo apps
    Listing ECS services in the dev cluster.
    +-------------------------------------+-----------------+---------+-------------+-----+------+
    |            Service Name             | Task Definition | Running | Launch type | Dns | Ufo? |
    +-------------------------------------+-----------------+---------+-------------+-----+------+
    | dev-demo-web-Ecs-3JCJA3QFYK1 (demo-web) | demo-web:286      | 8       | EC2         |     | yes  |
    +-------------------------------------+-----------------+---------+-------------+-----+------+


## Options

```
[--verbose], [--no-verbose]
[--mute], [--no-mute]
[--noop], [--no-noop]
[--cluster=CLUSTER]          # Cluster.  Overrides .ufo/settings.yml.
```

