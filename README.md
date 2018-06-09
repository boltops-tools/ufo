<div align="center">
  <img src="http://ufoships.com/img/logos/ufo-logo.png" />
</div>

# Ufo - ECS Deployment Tool

[![CircleCI](https://circleci.com/gh/tongueroo/ufo.svg?style=svg)](https://circleci.com/gh/tongueroo/ufo)
[![Join the chat at https://gitter.im/tongueroo/ufo](https://badges.gitter.im/tongueroo/ufo.svg)](https://gitter.im/tongueroo/ufo?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Support](https://img.shields.io/badge/get-support-blue.svg)](https://boltops.com?utm_source=badge&utm_medium=badge&utm_campaign=ufo)

Ufo is an tool that eases the building and deployment of docker images to [AWS ECS](https://aws.amazon.com/ecs/) super easy.

The main command is `ufo ship`.  Here's summary of what it does:

1. Builds a docker image. 
2. Generates and registers the ECS template definition. 
3. Deploys the ECS template definition to the ECS service.

Ufo deploys a task definition that is written in a templating language that is easily and fully controllable.

See [ufoships.com](http://ufoships.com) for full documentation.

## Important

If you are on version 2, you can run `ufo upgrade3` within your project to upgrade it to version 3.  Refer to the [CHANGELOG](CHANGELOG.md).

## Installation

```sh
gem install ufo
```

Full installation instructions are at [Install Ufo](http://ufoships.com/docs/install/).

## Quick Start

To quickly demonstrate how simple it is to use ufo we will use an example app from [tongueroo/hi](https://github.com/tongueroo/ufo).  The app is a barebones sinatra app.  Here are the steps:

```sh
gem install ufo
git clone https:///github.com/tongueroo/hi.git
cd hi
ufo init --app=hi --image=tongueroo/hi
ufo ship hi-web
```

Congratulations, you have successfully used ufo to deploy to an ECS service.


## Articles

* This blog post provides an introduction to the tool: [Ufo - Build Docker Containers and Ship Them to AWS ECS](https://medium.com/@tongueroo/ufo-easily-build-docker-containers-and-ship-them-to-aws-ecs-15556a2b39f#.qqu8o4wal).
* This presentation covers ufo also: [Ufo Ship on AWS ECS](http://www.slideshare.net/tongueroo/ufo-ship-for-aws-ecs-70885296)


## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/tongueroo/ufo/issues](https://github.com/tongueroo/ufo/issues).

### QA Checklist

[QA Checklist](https://github.com/tongueroo/ufo/wiki/QA-Checklist) is a good list of things to check.
