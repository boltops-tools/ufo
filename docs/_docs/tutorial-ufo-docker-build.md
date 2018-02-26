---
title: Build Docker
---

## Build the Docker Image

Let's use the `ufo docker build` command to build the docker image. The command uses the `Dockerfile` in the current project to build the docker image.  You use your own Dockerfile so you have fully control over how you would like the image to be built.  For this tutorial we will continue to use the [tongueroo/hi](https://github.com/tongueroo/hi) app and it's Dockerfile. Let's run the command:

```sh
ufo docker build
```

You should see similar output (some of the output has been truncated for conciseness):

```sh
$ ufo docker build
Building docker image with:
  docker build -t tongueroo/hi:ufo-2017-06-11T22-18-03-a18aa30 -f Dockerfile .
Sending build context to Docker daemon 734.2 kB
Step 1 : FROM ruby:2.3.3
 ---> 0e1db669d557
Step 2 : RUN apt-get update &&   apt-get install -y     build-essential     nodejs &&   rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get purge
 ---> Using cache
 ---> 931ace833716
...
Step 7 : ADD . /app
 ---> fae2452e6c35
Removing intermediate container 4c93f92a7fd8
Step 8 : RUN bundle install --system
 ---> Running in f851b9cb7d27
Using rake 12.0.0
Using i18n 0.8.1
...
Using web-console 2.3.0
Bundle complete! 12 Gemfile dependencies, 56 gems now installed.
Bundled gems are installed into /usr/local/bundle.
 ---> 194830c5c1a8
...
Removing intermediate container 67545cd4cd09
Step 11 : CMD bin/web
 ---> Running in b1b26e68d957
 ---> 8547bb48b21f
Removing intermediate container b1b26e68d957
Successfully built 8547bb48b21f
Docker image tongueroo/hi:ufo-2017-06-11T22-18-03-a18aa30 built.  Took 33s.
$
```

As you can see `ufo docker build` effectively shells out and calls `docker build -t tongueroo/hi:ufo-2017-06-11T22-18-03-a18aa30 -f Dockerfile .`.  The docker image tag that is generated contains a useful timestamp and the current HEAD git sha of the project that you are on.

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
Pushed tongueroo/hi:ufo-2017-06-11T22-22-32-a18aa30 docker image. Took 9s.
```


Note in order to push the image to a registry you will need to login into the registry.  If you are using DockerHub use the `docker login` command.  If you are using AWS ECR then you can use the `aws ecr get-login` command.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ufo-init.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-ufo-tasks-build.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

