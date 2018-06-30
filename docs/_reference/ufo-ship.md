---
title: ufo ship
reference: true
---

## Usage

    ufo ship SERVICE

## Description

Builds and ships container image to the ECS service.

The main command you use when using ufo is: `ufo ship`.  This command:

1. builds the docker image
2. registers the generated ECS task definition
3. deploys the definition to AWS ECS

Basic usage is:

    ufo ship demo-web

The ECS service gets created if the service does not yet exist on the cluster.

### Conventions

By convention the task and service names match. If you need override to this convention then you can specific the task.  For example if you want to ship to the `demo-web-1` service and use the `demo-web` task, run:

    ufo ship demo-web-1 --task demo-web

## Options in Detail

The command has a decent amount of options, you can see the options available with `ufo ship -h`.  The table below covers some of the options in detail:

{% include ufo-ship-options.md %}

As you can see there are plenty of options for `ufo ship`.  Let's demonstrate usage of them in a few examples.

### Load Balancer

ECS services can be associated with a Load Balancer upon creation. Ufo can automatically create a load balancer.  The options:

1. Automatically create the ELB.
2. Provide a target group from an existing ELB.
3. No ELB is created.

Here are examples for each of them:

    ufo ship demo-web --elb=true

    # Use existing target group from pre-created ELB:
    ufo ship demo-web --elb=arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/target-name/2378947392743

    # Disable creating elb and prompt:
    ufo ship demo-web --elb=false

Note, if the docker container's name is web then the `--elb` flag defaults to true automatically.

If you need to create a network load balancer with pre-allocated EIPs, you can use `--elb-eip-ids`, example:

    ufo deploy demo-web --elb-eip-ids eipalloc-a8de9ca0 eipalloc-a8de9ca0

More info available at the [load balancer docs](http://ufoships.com/docs/load-balancer/).

### Deploying Task Definition without Docker Build

Let's you want skip the docker build phase and only want use ufo to deploy a task definition. You can do this with the `ufo deploy` command.  Refer to [ufo deploy](http://ufoships.com/reference/ufo-deploy/) for more info.

### Waiting for Deployments to Complete

By default when ufo updates the ECS service with the new task definition it does so asynchronuously. You then normally visit the ECS service console and then refresh until you see that the deployment is completed.  You can also have ufo poll and wait for the deployment to be done with the `--wait` option

    ufo ship demo-web --wait

You should see output similar to this:

    Shipping demo-web...
    demo-web service updated on cluster with task demo-web
    Waiting for deployment of task definition demo-web:8 to complete
    ......
    Time waiting for ECS deployment: 31s.
    Software shipped!

### Route 53 DNS Support

Ufo can automatically create a "pretty" route53 record an set it to the created ELB dns name. This is done in by configuring the `.ufo/settings/network/[profile].yml` file. Example:

    dns:
      name: "{stack_name}.mydomain.com."
      hosted_zone_name: mydomain.com. # dont forget the trailing period

Refer to [Route53 Support](http://ufoships.com/docs/route53-support/) for more info.

### Cleaning up Docker Images Automatically

Since ufo builds the Docker image every time there's a deployment you will end up with a long list of docker images.  Ufo automatically cleans up older docker images at the end of the deploy process if you are using AWS ECR.  By default ufo keeps the most recent 30 Docker images. This can be adjust with the `--ecr-keep` option.

    docker ship demo-web --ecr-keep 2

You should see something like this:

    Cleaning up docker images...
    Running: docker rmi tongueroo/hi:ufo-2017-06-12T06-46-12-a18aa30

If you are using DockerHub or another registry, ufo does not automatically clean up images.


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
[--verbose], [--no-verbose]                
[--mute], [--no-mute]                      
[--noop], [--no-noop]                      
[--cluster=CLUSTER]                        # Cluster.  Overrides .ufo/settings.yml.
```

