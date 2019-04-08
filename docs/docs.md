---
title: Docs
nav_order: 10
---

## Overview

Ufo is a tool that makes deploying to AWS ECS easy. Ufo provides a `ufo ship` command that does this. It essentially:

1. ufo builds the docker container image
2. registers that image to ECS as a task definition
3. deploys that registered task definition to ECS by updating the service.
3. creates an ELB and associates it with the ECS service.

Ufo was built directly from real life production use cases after seeing the same patterns repeated over and over. Ufo enables you to write the AWS task definition json format file in ERB, an easy templating language.  This allows you to reuse the ufo tool with multiple applications and only put the truly application specific business logic in each app code base.

## Learn More

You might like these articles:

* [UFO and ECS Fargate Introduction Tutorial](https://blog.boltops.com/2018/07/11/ufo-and-ecs-fargate-introduction-tutorial)
* [UFO ECS Deploy Tool Introduction](https://blog.boltops.com/2018/07/06/ufo-ecs-deployment-tool-introduction)
* [UFO How to Create Unlimited Extra Environments](https://blog.boltops.com/2018/07/12/ufo-how-to-create-unlimited-extra-environments)
* [UFO Version 4 Release: Load Balancer Support](https://blog.boltops.com/2018/07/05/ufo-version-4-release)
* [Heroku vs ECS Fargate vs EC2 On-Demand vs EC2 Spot Pricing Comparison](https://blog.boltops.com/2018/04/22/heroku-vs-ecs-fargate-vs-ec2-on-demand-vs-ec2-spot-pricing-comparison)

Also, the [UFO Tutorial Docs]({% link _docs/tutorial.md %}) provide a detail walkthrough on how each UFO step works.

{% include prev_next.md %}