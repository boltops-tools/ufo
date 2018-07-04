---
title: ufo upgrade v3to4
reference: true
---

## Usage

    ufo upgrade v3to4

## Description

Upgrade from version 3 to 4.

## Examples

    ufo upgrade v3to4 --vpc-id vpc-123 --ecs-subnets subnet-111 subnet-222 --elb-subnets subnet-111 subnet-222


## Options

```
[--force]                      # Bypass overwrite are you sure prompt for existing files.
[--vpc-id=VPC_ID]              # Vpc id
[--ecs-subnets=one two three]  # Subnets for ECS tasks, defaults to --elb-subnets set to
[--elb-subnets=one two three]  # Subnets for ELB
```

