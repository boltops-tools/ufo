---
title: 'Quick Start: EC2'
nav_order: 2
---

## What is ECS EC2?

ECS EC2 is a way to run Docker containers on your own EC2 instances.  This difference between ECS EC2 and ECS Fargate is who manages the servers.  With ECS Fargate, AWS manages the EC2 instances for you and provides an interesting "serverless" option. With ECS EC2, you manage the EC2 instances and are responsible for maintenance.  The pro with ECS EC2 is more control and cost savings, since you're not paying for the overhead for AWS Fargate maintenance. Refer to [Heroku vs ECS Fargate vs EC2 On-Demand vs EC2 Spot Pricing Comparison](https://blog.boltops.com/2018/04/22/heroku-vs-ecs-fargate-vs-ec2-on-demand-vs-ec2-spot-pricing-comparison) for a pricing comparison.

## Let's Go

In a hurry? No sweat! Here's a quick start to using ufo that takes only a few minutes. For this example, we will use a Sinatra app from [tongueroo/demo-ufo](https://github.com/tongueroo/demo-ufo).  The `ufo init` command sets up the ufo directory structure in your project. The `ufo ship` command deploys your code to an AWS ECS service.  The `ufo ps` and `ufo scale` command shows you how to verify and scale additional containers.

    gem install ufo
    git clone https://github.com/tongueroo/demo-ufo.git demo
    cd demo
    ECR_REPO=$(aws ecr create-repository --repository-name demo/sinatra | jq -r '.repository.repositoryUri')
    ufo init --image $ECR_REPO
    ufo current --service demo-web
    ufo ship
    ufo ps
    ufo scale 2

This quickstart assumes:

* You have push access to the repo. Refer to the Notes "Repo Push Access" section below for more info.
* You are using ECS EC2 and have an ECS cluster with EC2 Container instances running. Refer to the Notes "ECS EC2 vs ECS Fargate" section below for more info.

## What Happened

The `ufo ship demo-web` command does the following:

1. Builds the Docker image and pushes it to a registry
2. Builds the ECS task definitions and registry them to ECS
3. Updates the ECS Service
4. Creates an ELB and connects it to the ECS Service

You should see something similar to this:

```
$ ufo init --app=demo --image=tongueroo/demo-ufo
Setting up ufo project...
      create  .env
      create  .ufo/settings.yml
      create  .ufo/task_definitions.rb
      create  .ufo/templates/main.json.erb
      create  .ufo/variables/base.rb
      create  .ufo/variables/development.rb
      create  .ufo/variables/production.rb
      create  Dockerfile
      create  bin/deploy
      append  .gitignore
Starter ufo files created.
$ ufo ship demo-web
Building docker image with:
  docker build -t 112233445566.dkr.ecr.us-west-2.amazonaws.com/demo/sinatra:ufo-2017-09-10T15-00-19-c781aaf -f Dockerfile .
....
Software shipped!
$ ufo ps
+----------+------+-------------+---------------+---------+-------+
|    Id    | Name |   Release   |    Started    | Status  | Notes |
+----------+------+-------------+---------------+---------+-------+
| f590ee5e | web  | demo-web:85 | 1 minutes ago | RUNNING |       |
+----------+------+-------------+---------------+---------+-------+
$ ufo scale 2
Scale demo-web service in development cluster to 2
$
```

Congratulations! You have successfully deployed code to AWS ECS with ufo. It was really that simple 😁

{% include repo_push_access.md %}

## ECS EC2 vs ECS Fargate

Ufo does not create the EC2 servers themselves to run the ECS tasks. If you use `ufo ship` to deploy an application to ECS EC2 and have not set up the EC2 servers, then the CloudFormation update will not be able to provision the ECS tasks and eventually roll back. Essentially it cannot create the ECS tasks because there are no EC2 servers to run them.

Refer to the AWS [Creating a Cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create_cluster.html) docs to create an ECS cluster. Also refer to [ECS Terms Tutorial](https://blog.boltops.com/2017/09/08/aws-ecs-terms-tutorial) for an explanation of ECS terms.

If you would like not to manage the EC2 server fleet, you are looking for ECS Fargate instead of ECS EC2.  ECS Fargate allows you to run ECS Tasks and AWS will manage the EC2 server fleet for you. Refer to the [Quick Start: Fargate]({% link quick-start.md %}) docs and use those quick start like commands instead.  The pricing for Fargate is more because AWS manages the server fleet for you. Refer to [Heroku vs ECS Fargate vs EC2 On-Demand vs EC2 Spot Pricing Comparison](https://blog.boltops.com/2018/04/22/heroku-vs-ecs-fargate-vs-ec2-on-demand-vs-ec2-spot-pricing-comparison) for a pricing comparison.

Learn more in the next sections.

{% include prev_next.md %}