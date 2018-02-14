---
title: ufo docker push
---

The `ufo docker push` command pushes the most recent Docker image built by `ufo docker build` to a registry.  Example:

```sh
ufo docker build # to build the image
ufo docker name  # to see the image name
ufo docker push  # push up the registry
```

You'll see that `ufo docker push` simply shells out and calls `docker push`:

```
$ ufo docker push
=> docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/hi:ufo-2018-02-13T10-51-44-e0cc7be
The push refers to a repository [123456789.dkr.ecr.us-east-1.amazonaws.com/hi]
399c739c257d: Layer already exists
...
Pushed 123456789.dkr.ecr.us-east-1.amazonaws.com/hi:ufo-2018-02-13T10-51-44-e0cc7be docker image. Took 1s.
$
```

You can also specify your own custom image to push as a parameter.

```
ufo docker push my/image:tag
```

You could also use the `--push` flag as part of the `ufo docker build` command to achieve the same thing as `ufo docker push`. Some find that `ufo docker push` is more intutitive.

```sh
ufo docker build --push # same as above
```

## Docker Authorization

Note in order to push the image to a registry you will need to login into the registry.  If you are using DockerHub use the `docker login` command.  If you are using AWS ECR then, ufo will automatically try to authorize you and configure your `~/.docker/config.json`.  If can also use `aws ecr get-login` command.

<a id="prev" class="btn btn-basic" href="{% link _docs/ufo-docker-build.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-docker-base.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
