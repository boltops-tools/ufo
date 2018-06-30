---
title: ufo ps
reference: true
---

## Usage

    ufo ps SERVICE

## Description

Show process info on ECS service.

## Examples

    $ ufo ps
    => Service: demo-web
       Service name: dev-demo-web-Ecs-17A82H7M463KT
       Status: ACTIVE
       Running count: 1
       Desired count: 1
       Launch type: EC2
       Task definition: demo-web:341
       Dns: dev-hi-Elb-S8ZBDGNPV7SV-5e2dadd7ccdecd8d.elb.us-east-1.amazonaws.com
    +----------+------+------------+----------------+---------+
    |    Id    | Name |  Release   |    Started     | Status  |
    +----------+------+------------+----------------+---------+
    | bf0b183d | web  | demo-web:341 | 13 minutes ago | RUNNING |
    +----------+------+------------+----------------+---------+

Skip the summary info:

    $ ufo ps --no-summary
    +----------+------+------------+----------------+---------+
    |    Id    | Name |  Release   |    Started     | Status  |
    +----------+------+------------+----------------+---------+
    | bf0b183d | web  | demo-web:341 | 13 minutes ago | RUNNING |
    +----------+------+------------+----------------+---------+


## Options

```
[--summary], [--no-summary]  # Display summary header info.
                             # Default: true
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides .ufo/settings.yml.
```

