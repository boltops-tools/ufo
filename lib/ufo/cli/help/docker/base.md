The docker cache task builds a docker image using the `Dockerfile.base` file and
updates the FROM `Dockerfile` image with the generated image from `Dockerfile.base`.

## Summarized Example

    ufo docker base
    ufo docker base --no-push # do not push the image to the registry

Docker image `org/repo:base-2016-10-21T15-50-57-88071f5` built.

## Detailed Example

Let's see the command in action:

    $ ufo docker base
    Building docker image with:
      docker build -t org/repo:base-2017-06-12T14-36-44-2af505e -f Dockerfile.base .
      ...
    Pushed org/repo:base-2017-06-12T14-36-44-2af505e docker image. Took 28s.
    The Dockerfile FROM statement has been updated with the latest base image:
      org/repo:base-2017-06-12T14-36-44-2af505e

Some of the output has been excluded so we can focus on the essential parts to point out. First, notice that the command simply shells out to the docker command and calls:

    docker build -t org/repo:base-2017-06-12T14-36-44-2af505e -f Dockerfile.base .

It uses the docker `-f Dockerfile.base` option to build the base image.  It names the image with `org/repo:base-2017-06-12T14-36-44-2af505e`.  The image tag contains useful information: the timestamp and exact git sha of the code.  The image gets pushed to a registry immediately.

## Dockerfile FROM updated

Notice at the very end, the *current* `Dockerfile`'s FROM statement has been updated with the newly built base Docker image automatically.  This saves you from forgetting to copy and paste it the `Dockerfile` yourself.

If you're using a [Dockerfile.erb](https://ufoships.com/docs/extras/dockerfile-erb/), then ufo will update the `.ufo/state/data.yml` file instead.  It assumes you're using a `Dockerfile.erb` that looks something like this:

```Dockerfile
FROM <%= @base_image %>
# ...
CMD ["bin/web"]
```
