---
title: Run in Pieces
---

The `ufo ship` command goes through a few stages: building the docker image, registering the task defiintions and updating the ECS service.  The CLI exposes each of the steps as separate commands.  Here is now you would be able to run each of the steps in pieces.

Build the docker image first.

```bash
ufo docker build
ufo docker build --push # will also push to the docker registry
```

Build the task definitions.

```bash
ufo tasks build
ufo tasks register # will register all genreated task definitinos in the ufo/output folder
```

Skips all the build docker phases of a deploy sequence and only update the service with the task definitions.

```bash
ufo ship hi-web --no-docker
```
Note if you use the `--no-docker` option you should ensure that you have already push a docker image to your docker registry.  Or else the task will not be able to spin up because the docker image does not exist.  It is normally recommended that you normally use `ufo ship`.

<a id="prev" class="btn btn-basic" href="{% link _docs/conventions.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/single-task.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
