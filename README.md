<div align="center">
  <img src="http://ufoships.com/img/logos/ufo-logo.png" />
</div>

# UFO: ECS Deploy Tool

[![CircleCI](https://circleci.com/gh/tongueroo/ufo.svg?style=svg)](https://circleci.com/gh/tongueroo/ufo)
[![Join the chat at https://gitter.im/tongueroo/ufo](https://badges.gitter.im/tongueroo/ufo.svg)](https://gitter.im/tongueroo/ufo?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Support](https://img.shields.io/badge/get-support-blue.svg)](https://boltops.com?utm_source=badge&utm_medium=badge&utm_campaign=ufo)

[![BoltOps Badge](https://img.boltops.com/boltops/badges/boltops-badge.png)](https://www.boltops.com)

Please **watch/star** this repo to help grow and support the project.

Ufo is a tool that builds Docker images and deploys them to [AWS ECS](https://aws.amazon.com/ecs/).  The main command is `ufo ship`.  Here's summary of what it does:

1. Builds a docker image.
2. Generates and registers the ECS template definition.
3. Deploys the ECS template definition to the ECS service.

Ufo deploys a task definition that is written in a templating language that is easily and fully controllable.

See [ufoships.com](http://ufoships.com) for full documentation.

## Important

If you are upgrading, please refer to the [Upgrading docs](https://ufoships.com/docs/upgrading/)

## Installation

    gem install ufo

Full installation instructions are at [Install Ufo](http://ufoships.com/docs/install/).

## Quick Start

To quickly demonstrate how simple it is to use ufo we will use an example app from [tongueroo/demo-ufo](https://github.com/tongueroo/demo-ufo).  The app is a barebones sinatra app.  Here are the steps:

    gem install ufo
    git clone https://github.com/tongueroo/demo-ufo.git demo
    cd demo
    ufo init --image=tongueroo/demo-ufo
    ufo ship demo-web

Congratulations, you have successfully used ufo to deploy to an ECS service.

## Load Balancer Support

Ufo can also create a load balancer as part of creating the ECS service if you wish. Underneath the hood, ufo uses CloudFormation to create the load balancer.  More information can be found at the [load balancer support docs](https://ufoships.com/docs/extras/load-balancer/).

## Articles

* [UFO How to Create Unlimited Extra Environments](https://blog.boltops.com/2018/07/12/ufo-how-to-create-unlimited-extra-environments)
* [UFO and ECS Fargate Introduction Tutorial](https://blog.boltops.com/2018/07/11/ufo-and-ecs-fargate-introduction-tutorial)
* [UFO ECS Deployment Tool Introduction](https://blog.boltops.com/2018/07/06/ufo-ecs-deployment-tool-introduction)
* [UFO Version 4 Release: Load Balancer Support](https://blog.boltops.com/2018/07/05/ufo-version-4-release)
* [UFO Ship on AWS ECS Presentation](http://www.slideshare.net/tongueroo/ufo-ship-for-aws-ecs-70885296)

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/tongueroo/ufo/issues](https://github.com/tongueroo/ufo/issues).

### QA Checklist

[QA Checklist](https://github.com/tongueroo/ufo/wiki/QA-Checklist) is a good list of things to check.
