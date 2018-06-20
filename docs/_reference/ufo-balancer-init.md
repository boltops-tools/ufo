---
title: ufo network init
reference: true
---

## Usage

    ufo network init

## Description

Creates balancer starter file.

## Examples

    ufo network init # will use default vpc and subnets
    ufo network init --vpc-id vpc-123
    ufo network init --vpc-id vpc-123 --subnets subnet-aaa subnet-bbb
    ufo network init --launch-type fargate

If the `--vpc-id` option but the `--subnets` is not, then ufo generates files with subnets from the specified vpc id.

The `--launch-type fargate` option generates files with the proper fargate parameters.


## Options

```
[--force]                          # Bypass overwrite are you sure prompt for existing files.
[--launch-type=LAUNCH_TYPE]        # Launch type: ec2 or fargate.
[--subnets=one two three]          # Subnets
[--security-groups=one two three]  # Security groups
[--vpc-id=VPC_ID]                  # Vpc id
```

