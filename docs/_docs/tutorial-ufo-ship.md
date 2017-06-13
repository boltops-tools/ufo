---
title: ufo ship
---

### Step 3 - Ship the Code to ECS

In this guide we have walked through what ufo does step by step.  First ufo builds the Docker image with `ufo docker build`.  Then it will build and register the ECS task definitions with the `ufo tasks` commands. Now we'll deploy the code to ECS.

```sh
ufo ship hi-web-stag
```

The output should look something like this (some of the output has been removed for conciseness):

```sh
$ ufo ship hi-web-stag
Building docker image with:
  docker build -t tongueroo/hi:ufo-2017-06-12T06-46-12-a18aa30 -f Dockerfile .
...
Pushed tongueroo/hi:ufo-2017-06-12T06-46-12-a18aa30 docker image. Took 9s.
Building Task Definitions...
Generating Task Definitions:
  ufo/output/hi-web-stag.json
  ufo/output/hi-worker-stag.json
  ufo/output/hi-clock-stag.json
Task Definitions built in ufo/output.
hi-web-stag task definition registered.
Shipping hi-web-stag...
hi-web-stag service updated on stag cluster with task hi-web-stag
Software shipped!
Cleaning up docker images...
Running: docker rmi tongueroo/hi:ufo-2017-06-11T20-32-16-a18aa30 tongueroo/hi:ufo-2017-06-11T20-27-44-bc80e84 tongueroo/hi:ufo-2017-06-11T20-02-18-bc80e84
```

Checking the ECS console you should see something like this:

<img src="/img/tutorials/ecs-console-ufo-ship.png" class="doc-photo" />

### Skipping Previous Steps

The `ufo ship` command will automatically calls the steps we called manually in the previous pages: `ufo build` and `ufo tasks`.

If you would like to skip the first 2 steps you can use the `--no-docker` and `--no-tasks` flags:

```sh
ufo ship hi-web-stag --no-docker --no-tasks
```

The output should look something like this:

```sh
Shipping hi-web-stag...
hi-web-stag service updated on stag cluster with task hi-web-stag
Software shipped!
```

Normally you run everything together in one `ufo ship` command though.  Ufo takes a multiple step process and simplifies it down to a single command!

Congratulations 🎊 You have successfully built a Docker image, register it and deployed it to AWS ECS.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ufo-tasks-build.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-ufo-ships.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

