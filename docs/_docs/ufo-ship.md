---
title: ufo ship
---

The main command you use when using ufo is: `ufo ship`.  This command builds the docker image, registers the generated ECS task definition and deploys the definition to AWS ECS all in one go.

The command has a decent amount of options, you can see the options available with `ufo ship -h`.  The table below covers some of the options in detail:

{% include ufo-ship-options.md %}

As you can see there are plenty of options for `ufo ship`.  Let's demonstrate usage of them in a few examples:

#### Load Balancer Target Group

When you are deploying to a service with the word 'web' in it, ufo by convention assumes that this is a web service that uses a load balancer in front of it.  This is also covered a in the [Conventions]({% link _docs/conventions.md %}) page.  If you would you like to create a service with the word web without an load balancer associated with it you can use the `--no-target-group-prompt` option:

```sh
ufo ship hi-web --no-target-group-prompt
```

Or if you would like specify the target-group up front and not be bother with the prompted later you can use the `--target-group` option.

```sh
ufo ship hi-web --target-group=arn:aws:elasticloadbalancing:us-east-1:12345689:targetgroup/hi-web/12345
```

#### Deploying Existing Task Definition

Let's say you already have built an registered a task definition by some other means and only want to use ufo to deploy that already registered task definition. You can do this by skipping the task build and register phase. It probably also makes sense to skip the docker phase in this case.

```sh
ufo ship hi-web --no-docker --no-tasks
```

#### Waiting for Deployments to Complete

By default when ufo updates the ECS service with the new task definition it does so asynchronuously. You then normally visit the ECS service console and then refresh until you see that the deployment is completed.  You can also have ufo poll and wait for the deployment to be done with the `--wait` option

```sh
ufo ship hi-web --wait
```

You should see output similar to this:

```sh
Shipping hi-web...
hi-web service updated on cluster with task hi-web
Waiting for deployment of task definition hi-web:8 to complete
......
Time waiting for ECS deployment: 31s.
Software shipped!
```

#### Cleaning up Docker Images Automatically

Since ufo builds the Docker image every time there's a deployment you will end up with a long list of docker images.  Ufo automatically cleans up older docker images at the end of the deploy process if you are using AWS ECR.  By default ufo keeps the most recent 30 Docker images. This can be adjust with the `--ecr-keep` option.

```sh
docker ship hi-web --ecr-keep 2
```

You should see something like this:

```sh
Cleaning up docker images...
Running: docker rmi tongueroo/hi:ufo-2017-06-12T06-46-12-a18aa30
```

If you are using DockerHub or another registry, ufo does not automatically clean up images.


<a id="prev" class="btn btn-basic" href="{% link _docs/ufo-init.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-ships.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

