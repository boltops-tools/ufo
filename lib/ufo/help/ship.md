The main command you use when using ufo is: `ufo ship`.  This command:

1. builds the docker image
2. registers the generated ECS task definition
3. deploys the definition to AWS ECS

Basic usage is:

    ufo ship hi-web

The ECS service gets created if the service does not yet exist on the cluster.

### Conventions

By convention the task and service names match. If you need override to this convention then you can specific the task.  For example if you want to ship to the `hi-web-1` service and use the `hi-web` task, run:

    ufo ship hi-web-1 --task hi-web

## Options in Detail

The command has a decent amount of options, you can see the options available with `ufo ship -h`.  The table below covers some of the options in detail:

{% include ufo-ship-options.md %}

As you can see there are plenty of options for `ufo ship`.  Let's demonstrate usage of them in a few examples.

### Load Balancer

ECS services can be associated with a Load Balancer upon creation. Ufo can automatically create a load balancer.  The options:

1. Automatically create the ELB.
2. Provide a target group from an existing ELB.
3. No ELB is created and associated.

Here are examples for each of them:

    # Use different profiles to create the ELB:
    #  .ufo/balancer/profiles/default.yml
    #  .ufo/balancer/profiles/production.yml
    ufo ship hi-web --elb=default
    ufo ship hi-web --elb=production

    # Use existing target group from pre-created ELB:
    ufo ship hi-web --elb=arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/target-name/2378947392743
    ufo ship hi-web --target-group=arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/target-name/2378947392743 # legacy, currently works

    # Disable creating elb and prompt:
    ufo ship hi-web --elb=false

More info available at the [load balancer docs](http://ufoships.com/docs/load-balancer/).

### Deploying Task Definition without Docker Build

Let's you want skip the docker build phase and only want use ufo to deploy a task definition. You can do this with the `ufo deploy` command.  Refer to [ufo deploy](http://ufoships.com/reference/ufo-deploy/) for more info.

### Waiting for Deployments to Complete

By default when ufo updates the ECS service with the new task definition it does so asynchronuously. You then normally visit the ECS service console and then refresh until you see that the deployment is completed.  You can also have ufo poll and wait for the deployment to be done with the `--wait` option

    ufo ship hi-web --wait

You should see output similar to this:

    Shipping hi-web...
    hi-web service updated on cluster with task hi-web
    Waiting for deployment of task definition hi-web:8 to complete
    ......
    Time waiting for ECS deployment: 31s.
    Software shipped!

### Cleaning up Docker Images Automatically

Since ufo builds the Docker image every time there's a deployment you will end up with a long list of docker images.  Ufo automatically cleans up older docker images at the end of the deploy process if you are using AWS ECR.  By default ufo keeps the most recent 30 Docker images. This can be adjust with the `--ecr-keep` option.

    docker ship hi-web --ecr-keep 2

You should see something like this:

    Cleaning up docker images...
    Running: docker rmi tongueroo/hi:ufo-2017-06-12T06-46-12-a18aa30

If you are using DockerHub or another registry, ufo does not automatically clean up images.

