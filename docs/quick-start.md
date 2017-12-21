---
title: Quick Start
---

In a hurry? No sweat! Here's a quick start to using ufo that takes only a few minutes. For this example, we will use a sinatra app from [tongueroo/hi](https://github.com/tongueroo/ufo).  The first `ufo init` command sets up the ufo directory structure in your project. The second `ufo ship` command deploys your code to an AWS ECS service.

```sh
gem install ufo
git clone https://github.com/tongueroo/hi.git
cd hi
ufo init --app=hi --image=tongueroo/hi
ufo ship hi-web
```

You should see something similar to this:

```
$ ufo init --app=hi --image=tongueroo/hi
Setting up ufo project...
created: ./bin/deploy
created: ./Dockerfile
created: ./ufo/settings.yml
created: ./ufo/task_definitions.rb
created: ./ufo/templates/main.json.erb
created: ./ufo/variables/base.rb
created: ./ufo/variables/prod.rb
created: ./ufo/variables/stag.rb
created: ./.env
Starter ufo files created.
$ ufo ship hi-web
Building docker image with:
  docker build -t tongueroo/hi:ufo-2017-09-10T15-00-19-c781aaf -f Dockerfile .
....
Software shipped!
$
```
Congratulations! You have successfully deployed code to AWS ECS with ufo. It was really that simple 😁

Note: This quick start does require that you have a docker working on your environment.  For docker installation instructions refer to to the official [docker installation guide](https://docs.docker.com/engine/installation/).

Learn more in the next sections.

<a id="next" class="btn btn-primary" href="{% link docs.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

