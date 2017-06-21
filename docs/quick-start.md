---
title: Quick Start
---

In a hurry? No sweat! Here's a quick start to using ufo that takes only a few minutes. For this example, we will use a sinatra app from [tongueroo/hi](https://github.com/tongueroo/ufo).  The first `ufo init` command sets up the ufo directory structure in your project. The second `ufo ship` command deploys your code to an AWS ECS service.

```sh
brew cask install boltopslabs/software/bolts
git clone https:///github.com/tongueroo/hi.git
cd hi
ufo init --app=hi --env stag --cluster=stag --image=tongueroo/hi
ufo ship hi-web-stag
```

You should see something similar to this:

<img src="/img/tutorials/ufo-init.png" class="doc-photo" />

Congratulations! You have successfully deployed code to AWS ECS with ufo. It was really that simple 😁

Note: This quick start does require that you have a docker working on your environment.  For docker installation instructions refer to to the official [docker installation guide](https://docs.docker.com/engine/installation/).

Learn more in the next sections.

<a id="next" class="btn btn-primary" href="{% link docs.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

