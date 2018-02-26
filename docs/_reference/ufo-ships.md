---
title: ufo ships
reference: true
---

## Usage

    ufo ships [LIST_OF_SERVICES]

## Description

Builds and ships same container image to multiple ECS services.

The `ufo ships` command allows you to deploy the *same* Docker image and task definition to multiple ECS services.  It is a common pattern to have the same code base running on different roles.  For example, say you have an application with 3 roles:

1. web - serves web requests.
2. worker - processes background jobs.
3. clock - schedules background jobs.

Instead of using the [ufo ship]({% link _reference/ufo-ship.md %}) and build and deploying the code 3 times you can instead use `ufo ships`.  This will result in the *same* Docker image and *same* task definition being deployed to all 3 services.  Example usage:

```sh
ufo ships hi-web hi-worker hi-clock
```

## Shell expansion

Since the ECS service names are provided as a list you can shorten the command by using bash shell expansion 😁

```sh
ufo ships hi-{web,worker,clock}
```

If you're new to shell expansion, run this to understand why above works just as well:

```sh
$ echo hi-{web,worker,clock}
hi-web hi-worker hi-clock
```

## Overriding convention

As explained in detail in [Conventions]({% link _docs/conventions.md %}) the task definition and service name are the same by convention.  This convention also applies for each of the services being shipped in the list. The task definition and service names match for each of the services in the list.  If you would like to override the convention as part of the ships command then you use a special syntax. In the special syntax the service and task definition is separated by a colon.  Examples:

```sh
ufo ships hi-web-1:hi-web hi-clock-1 hi-worker-1
ufo ships hi-web-1:my-task hi-clock-1:another-task hi-worker-1:third-task
```

## ufo ships Options

The `ufo ships`, `ufo ship`, `ufo deploy` command support the same options. The options are presented here again for convenience:

{% include ufo-ship-options.md %}

Note: The `--task` option is not used with the `ufo ships` command.

## ELB Target Group

For each service being deployed to, ufo will create the ECS service if the service does not yet exist on the cluster.  The deploy process will prompt you for the ELB `--target-group` if you are deploying to a 'web' service that does not yet exist.  Ufo determines that it is a web service by the name of the service. If the service has 'web' in the name then it is considered a web service. If it is not a web service then the `--target-group` option gets ignored.

The prommt can be bypassed by specifying a valid `--target-group` option or specifying the `---no-target-group-prompt` option.  ## Examples

    ufo ships hi-web hi-clock hi-worker --target-group arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/hi-web/jsdlfjsdkd
    ufo ships hi-web hi-clock hi-worker --no-target-group-prompt


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

