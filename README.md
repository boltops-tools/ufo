![Ufo Logo](http://ufoships.com/img/logos/ufo-logo.png "Ufo Shipping Docker")

# Ufo - Easy Way to Build and Ship Docker to AWS ECS

[![CircleCI](https://circleci.com/gh/tongueroo/ufo.svg?style=svg)](https://circleci.com/gh/tongueroo/ufo)

Ufo is a tool that makes building and shipping Docker images to [AWS ECS](https://aws.amazon.com/ecs/) super easy.

The main command is `ufo ship`.  Here's summary of what it does:

1. Builds a docker image. 
2. Generates and registers the ECS template definition. 
3. Deploys the ECS template definition to the ECS service.

Ufo deploys a task definition that is written in a templating language that is easily and fully controllable.

See [ufoships.com](http://ufoships.com) for full documentation.

## Installation

If you want to quickly install ufo without having to worry about ufo’s dependencies you can simply install the Bolts Toolbelt which has ufo included.

```sh
brew cask install boltopslabs/software/bolts
```

Or if you prefer you can install ufo with RubyGems

```sh
gem install ufo
```

Full installation instructions are at [Install Ufo](http://ufoships.com/docs/install/).

## Quick Start

To quickly demonstrate how simple it is to use ufo we will use an example app from [tongueroo/hi](https://github.com/tongueroo/ufo).  The app is a barebones sinatra app.  Here are the steps:

```sh
brew cask install boltopslabs/software/bolts
git clone https:///github.com/tongueroo/hi.git
cd hi
ufo init --app=hi --env stag --cluster=stag --image=tongueroo/hi
ufo ship hi-web-stag
```

Congratulations, you have successfully used ufo to deploy to an ECS service.


## Articles

* This blog post provides an introduction to the tool: [Ufo - Build Docker Containers and Ship Them to AWS ECS](https://medium.com/@tongueroo/ufo-easily-build-docker-containers-and-ship-them-to-aws-ecs-15556a2b39f#.qqu8o4wal).
* This presentation covers ufo also: [Ufo Ship on AWS ECS](http://www.slideshare.net/tongueroo/ufo-ship-for-aws-ecs-70885296)


## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/tongueroo/ufo/issues](https://github.com/tongueroo/ufo/issues).
