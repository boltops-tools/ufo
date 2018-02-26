---
title: ufo docker
reference: true
---

## Usage

    ufo docker SUBCOMMAND

## Description

docker subcommands

## Examples

    ufo docker build
    ufo docker tag

## Subcommands

* [ufo docker base]({% link _reference/ufo-docker-base.md %}) - builds docker image from Dockerfile.base and update current Dockerfile
* [ufo docker build]({% link _reference/ufo-docker-build.md %}) - builds docker image
* [ufo docker clean]({% link _reference/ufo-docker-clean.md %}) - Cleans up old images. Keeps a specified amount.
* [ufo docker name]({% link _reference/ufo-docker-name.md %}) - displays the full docker image with tag that was last generated.
* [ufo docker push]({% link _reference/ufo-docker-push.md %}) - push the docker image

## Options

```
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides ufo/settings.yml.
```

