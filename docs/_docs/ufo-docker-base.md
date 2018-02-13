---
title: ufo docker base
---

### Concept

Docker is fantastic and has given developers more power and control over the OS their application runs on.  Sometimes building Docker images can be slow though.  Docker layer caching technology helps immensely to speed up the process as Docker will only rebuild layers that require rebuilding. But sometimes one little dependency changes it results in having to rebuild many layers.

The `ufo docker base` commands allows you to build an Docker image from `Dockerfile.base` to be used as a cache and in the FROM instruction in the main `Dockerfile`.  This base Docker cache image technique speeds up development substantially if you have dependencies like gems in your project.  Let's say you have 20 gems in your project and are actively developing your project. You are experimenting with 3 different gems, adding and removing them while you are investigating the best gem to use.  Without the Docker image cache that already has all of your other gems installed each time you adjust `Gemfile` it would have to wait until all the gems from scratch again installed again.

There are pros and cons of using this approach.  Remember there are 2 hard problems in computer science: 1. Naming and 2. Caching.  The main con about this approach is if you forget to update the base Docker image you will have cached artifacts that will not disappear unless you rebuild the base Docker image.  While some folks are completely against introducing this cache layer, some have found it being a huge win in speeding up their Docker development workflow.  If you are using this technique it is recommended that you set up some automation that rebuilds the base Docker image at least nightly.

### Demo

To demonstrate this command, there's a `docker-cache` branch in the [tongueroo/hi](https://github.com/tongueroo/hi/tree/docker-cache) repo.

 Let's see the command in action:

```sh
ufo docker base
Building docker image with:
  docker build -t tongueroo/hi:base-2017-06-12T14-36-44-2af505e -f Dockerfile.base .
  ...
Pushed tongueroo/hi:base-2017-06-12T14-36-44-2af505e docker image. Took 28s.
The Dockerfile FROM statement has been updated with the latest base image:
  tongueroo/hi:base-2017-06-12T14-36-44-2af505e
```

Some of the output has been excluded so we can focus on the important parts to point out. First notice that the commmand simply shells out to the docker command and calls:

```sh
docker build -t tongueroo/hi:base-2017-06-12T14-36-44-2af505e -f Dockerfile.base .
```

It is using the docker `-f Dockerfile.base` option to build the base image.  It names the image with `tongueroo/hi:base-2017-06-12T14-36-44-2af505e`.  The image tag contains useful information: the timestamp when the image was built and the exact git sha of the code.  The image gets push to a registry immediately.

Notice at the very end, the *current* `Dockerfile`'s FROM statement has been updated with the newly built base Docker image automatically.  This saves you from forgetting to copying and pasting it the `Dockerfile` yourself.

<a id="prev" class="btn btn-basic" href="{% link _docs/ufo-docker-push.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-docker-name.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

