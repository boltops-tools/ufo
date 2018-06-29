---
title: Quick Start
---

In a hurry? No sweat! Here's a quick start to using ufo that takes only a few minutes. For this example, we will use a sinatra app from [tongueroo/demo-ufo](https://github.com/tongueroo/demo-ufo).  The first `ufo init` command sets up the ufo directory structure in your project. The second `ufo ship` command deploys your code to an AWS ECS service.

```sh
gem install ufo
git clone https://github.com/tongueroo/demo-ufo.git
cd demo-ufo
ufo init --app=demo --image=tongueroo/demo-ufo
ufo ship demo-web
```

## What Happened

The `ufo ship demo-web` command does the following:

1. Builds the Docker image and pushes it to a registry
2. Builds the ECS task definitions and registry them to ECS
3. Updates the ECS Service

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
  docker build -t tongueroo/hi:ufo-2017-09-10T15-00-19-c781aaf -f Dockerfile .
....
Software shipped!
$
```
Congratulations! You have successfully deployed code to AWS ECS with ufo. It was really that simple 😁

Note: This quick start does require that you have a docker working on your environment.  For docker installation instructions refer to to the official [docker installation guide](https://docs.docker.com/engine/installation/).

Learn more in the next sections.

<a id="next" class="btn btn-primary" href="{% link _docs/install.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

