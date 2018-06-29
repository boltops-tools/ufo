---
title: Deploy One App
---

## Step 3 - Ship the Code to ECS

In this guide we have walked through what ufo does step by step.  First ufo builds the Docker image with `ufo docker build`.  Then it will build and register the ECS task definitions with the `ufo tasks` commands. Now we'll deploy the code to ECS.

```sh
ufo ship demo-web
```

By convention, ufo will ship the docker container to an ECS cluster with the same value as UFO_ENV, which defaults to development.  So the command above is the same as:

```sh
ufo ship demo-web --cluster development
UFO_ENV=development ufo ship demo-web
```

When you run `ufo ship demo-web`:

1. It builds the docker image.
2. Generates a task definition and registers it.
3. Updates the ECS service to use it.

If the ECS service demo-web does not yet exist, ufo will create the service for you. Ufo will also automatically create the ECS cluster.

NOTE: Ufo creates the ECS cluster record, but you still need to associate ECS Container Instances to the cluster yourself.

By convention, if the service has a container name web, ufo will automatically create an Load Balancer.  Let's take a look at the example out from the `ufo ship`.  Some of the output has been removed for conciseness.

```sh
$ ufo ship demo-web
Building docker image with:
  docker build -t tongueroo/demo-ufo:ufo-2018-06-28T16-41-11-7e0af94 -f Dockerfile .
...
Deploying demo-web...
Ensuring log group for demo-web task definition exists
Log group name: ecs/demo-web
Creating stack development-demo-web...
Generated template saved at: /tmp/ufo/development-demo-web/stack.yml
Generated parameters saved at: /tmp/ufo/development-demo-web/parameters.yml
04:41:27PM CREATE_IN_PROGRESS AWS::CloudFormation::Stack development-demo-web User Initiated
04:41:31PM CREATE_IN_PROGRESS AWS::EC2::SecurityGroup ElbSecurityGroup
04:41:31PM CREATE_IN_PROGRESS AWS::EC2::SecurityGroup EcsSecurityGroup
04:41:31PM CREATE_IN_PROGRESS AWS::ElasticLoadBalancingV2::TargetGroup TargetGroup
04:41:31PM CREATE_IN_PROGRESS AWS::EC2::SecurityGroup ElbSecurityGroup Resource creation Initiated
04:41:32PM CREATE_IN_PROGRESS AWS::EC2::SecurityGroup EcsSecurityGroup Resource creation Initiated
04:41:32PM CREATE_IN_PROGRESS AWS::ElasticLoadBalancingV2::TargetGroup TargetGroup Resource creation Initiated
...
04:44:46PM CREATE_COMPLETE AWS::ECS::Service Ecs
04:44:48PM CREATE_COMPLETE AWS::CloudFormation::Stack development-demo-web
Stack success status: CREATE_COMPLETE
Time took for stack deployment: 3m 22s.
Software shipped!
$
```

Checking the ECS console you should see something like this:

<img src="/img/tutorials/ecs-console-ufo-ship.png" class="doc-photo" />

You have successfully deployed a Docker image to ECS! 🍾🥂

## Checking ECS Service

Another way to check that the ECS service is running is with the `ufo ps` command.

    $ ufo ps demo-web
    => Service: demo-web
       Service name: development-demo-web-Ecs-12DRF2703Z3D2
       Status: ACTIVE
       Running count: 1
       Desired count: 1
       Launch type: EC2
       Task definition: demo-web:82
       Elb: develop-Elb-ZY1VARS3KP14-2141687965.us-east-1.elb.amazonaws.com
    +----------+------+-------------+---------------+---------+-------+
    |    Id    | Name |   Release   |    Started    | Status  | Notes |
    +----------+------+-------------+---------------+---------+-------+
    | e4426421 | web  | demo-web:82 | 5 minutes ago | RUNNING |       |
    +----------+------+-------------+---------------+---------+-------+

## Ufo Current Tip

We've been typing the `demo-web` service name explicitly.  We can set the current service with the `ufo current` command to save us from typing each time.  Example:

    ufo current --service demo-web
    ufo ship # now same as ufo ship demo-web

Congratulations 🎊 You have successfully built a Docker image, register it and deployed it to AWS ECS.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ufo-tasks-build.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-ufo-ships.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
