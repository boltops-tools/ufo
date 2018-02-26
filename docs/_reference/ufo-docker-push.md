---
title: ufo docker push
reference: true
---

## Usage

    ufo docker push IMAGE

## Description

push the docker image

This command pushes a docker image up to the registry.  By default it pushes the last image that was built with `ufo docker build`.  To see what the image name is you can run `ufo docker name`. Example:

    ufo docker build # to build the image
    ufo docker name  # to see the image name
    ufo docker push  # push up the registry

You can also push up a custom image by specifying the image name as the first parameter.

    ufo docker push my/image:tag

The command also updates your ECR auth token in `~/.docker/config.json` in case it has expired.


## Options

```
[--push], [--no-push]  
```

