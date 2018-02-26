---
title: ufo ship
reference: true
---

## Usage

    ufo ship SERVICE

## Description

builds and ships container image to the ECS service

Examples:

To build the docker image, generate the task definition and ship it, run:

    ufo ship hi-web

By convention the task and service names match. If you need override to this convention then you can specific the task.  For example if you want to ship to the `hi-web-1` service and use the `hi-web` task, run:

    ufo ship hi-web-1 --task hi-web

The deploy will also created the ECS service if the service does not yet exist on the cluster.  The deploy will prompt you for the ELB `--target-group` if you are shipping a web container that does not yet exist.  If it is not a web container the `--target-group` option gets ignored.

The prommpt can be bypassed by specifying a valid `--target-group` option or specifying the `---no-target-group-prompt` option.

    ufo ship hi-web --target-group arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/hi-web/jsdlfjsdkd

    ufo ship hi-web --no-target-group-prompt


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

