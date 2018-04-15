---
title: ufo deploy
reference: true
---

## Usage

    ufo deploy SERVICE

## Description

Deploy task definition to ECS service without re-building the definition.

It is useful to sometimes deploy only the task definition without re-building it.  Say for example, you are debugging the task definition and just want to directly edit the `.ufo/output/hi-web.json` definition. You can accomplish this with the `ufo deploy` command.  The `ufo deploy` command will deploy the task definition in `.ufo/output` unmodified.  Example:

    ufo deploy hi-web

The above command does the following:

1. register the `.ufo/output/hi-web.json` task definition to ECS untouched.
2. deploys it to ECS by updating the service

### ufo tasks build

To regenerate a `.ufo/output/hi-web.json` definition:

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
[--task=TASK]                                        # ECS task name, to override the task name convention.
[--target-group=TARGET_GROUP]                        # ELB Target Group ARN.
[--target-group-prompt], [--no-target-group-prompt]  # Enable Target Group ARN prompt
                                                     # Default: true
[--wait], [--no-wait]                                # Wait for deployment to complete
[--pretty], [--no-pretty]                            # Pretty format the json for the task definitions
                                                     # Default: true
[--stop-old-tasks], [--no-stop-old-tasks]            # Stop old tasks after waiting for deploying to complete
[--ecr-keep=N]                                       # ECR specific cleanup of old images.  Specifies how many images to keep.  Only runs if the images are ECR images. Defaults keeps all images.
[--verbose], [--no-verbose]                          
[--mute], [--no-mute]                                
[--noop], [--no-noop]                                
[--cluster=CLUSTER]                                  # Cluster.  Overrides ufo/settings.yml.
```

