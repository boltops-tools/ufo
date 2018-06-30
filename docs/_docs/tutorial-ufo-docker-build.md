---
title: Build Docker
---

## Build the Docker Image

Let's use the `ufo docker build` command to build the docker image. The command uses the `Dockerfile` in the current project to build the docker image.  You use your own Dockerfile so you have fully control over how you would like the image to be built.  For this tutorial we will continue to use the [tongueroo/demo-ufo](https://github.com/tongueroo/demo-ufo) app and it's Dockerfile. Let's run the command:

```sh
ufo docker build
```

You should see similar output (some of the output has been truncated for conciseness):

```sh
$ ufo docker build
Building docker image with:
  docker build -t tongueroo/demo-ufo:ufo-2018-06-28T16-33-57-7e0af94 -f Dockerfile .
Sending build context to Docker daemon    128kB
Step 1/10 : FROM ruby:2.5.1
 ---> 857bc7ff918f
Step 2/10 : WORKDIR /app
 ---> Using cache
 ---> 4e93fbb496c9
...
Step 10/10 : CMD bin/web
 ---> Running in cd63ebaec8aa
 ---> 14852737c639
Removing intermediate container cd63ebaec8aa
Successfully built 14852737c639
Successfully tagged tongueroo/demo-ufo:ufo-2018-06-28T16-33-57-7e0af94
Docker image tongueroo/demo-ufo:ufo-2018-06-28T16-33-57-7e0af94 built.
Docker build took 2s.
```

As you can see `ufo docker build` shells out and calls `docker build -t tongueroo/demo-ufo:ufo-2017-06-11T22-18-03-a18aa30 -f Dockerfile .`.  The docker image tag that is generated contains a useful timestamp and the current HEAD git sha of the project that you are on.

By default when you are running `ufo docker build` directly it does not push the docker image to the registry.  If you would like it to push the built image to a registry at the end of the build use the `--push` flag.

```sh
ufo docker build --push
```

You can also use the `ufo docker push` command which will push the last built image from `ufo docker build`.

```
ufo docker push
```

You should see the image being pushed with a message that looks something like this:

```sh
Pushed tongueroo/demo-ufo:ufo-2018-06-28T16-33-57-7e0af94 docker image.
Docker push took 12s.
```


Note in order to push the image to a registry you will need to login into the registry.  If you are using DockerHub use the `docker login` command.  If you are using AWS ECR then ufo automatically calls the `aws ecr get-login` command and authenticates for you.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ufo-init.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-ufo-tasks-build.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

