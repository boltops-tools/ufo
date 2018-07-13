---
title: ufo deploy
reference: true
---

## Usage

    ufo deploy SERVICE

## Description

Deploy task definition to ECS service without re-building the definition.

It is useful to sometimes deploy only the task definition without re-building it.  Say for example, you are debugging the task definition and just want to directly edit the `.ufo/output/demo-web.json` definition. You can accomplish this with the `ufo deploy` command.  The `ufo deploy` command will deploy the task definition in `.ufo/output` unmodified.  Example:

    ufo deploy demo-web

The above command does the following:

1. register the `.ufo/output/demo-web.json` task definition to ECS untouched.
2. deploys it to ECS by updating the service

### ufo tasks build

To regenerate a `.ufo/output/demo-web.json` definition:

    ufo tasks build

### ufo ship

The `ufo deploy` command does less than the `ufo ship` command.  Normally, it is recommended to use `ufo ship` over the `ufo deploy` command to do everything in one step:

1. build the Docker image
2. register the ECS task definition
3. update the ECS service

The `ufo ships`, `ufo ship`, `ufo deploy` command support the same options. The options are presented here again for convenience:

{% include ufo-ship-options.md %}


## Options

```
[--ecr-keep=N]                             # ECR specific cleanup of old images.  Specifies how many images to keep.  Only runs if the images are ECR images. Defaults keeps all images.
[--elb=ELB]                                # Decides to create elb, not create elb or use existing target group.
[--elb-eip-ids=one two three]              # EIP Allocation ids to use for network load balancer.
[--elb-type=ELB_TYPE]                      # ELB type: application or network. Keep current deployed elb type when not specified.
[--pretty], [--no-pretty]                  # Pretty format the json for the task definitions
                                           # Default: true
[--stop-old-tasks], [--no-stop-old-tasks]  # Stop old tasks as part of deployment to speed it up
[--task=TASK]                              # ECS task name, to override the task name convention.
[--wait], [--no-wait]                      # Wait for deployment to complete
                                           # Default: true
[--register], [--no-register]              # Register task definition
                                           # Default: true
[--verbose], [--no-verbose]                
[--mute], [--no-mute]                      
[--noop], [--no-noop]                      
[--cluster=CLUSTER]                        # Cluster.  Overrides .ufo/settings.yml.
```

