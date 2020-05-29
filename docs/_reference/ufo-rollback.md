---
title: ufo rollback
reference: true
---

## Usage

    ufo rollback SERVICE VERSION

## Description

Rolls back to older task definition.

## Examples

You only need to specific the task definition version number, though you can specify the name also

    ufo rollback demo-web 1
    ufo rollback demo-web demo-web:1

To see recent task definitions:

    ufo releases

If you set a current service with `ufo current`, then the commands get shorten:

    ufo rollback demo-web:1
    ufo rollback 1

Note, task definitions get created by many ways with more than just `ufo ship`. So it the previous version might not be the latest version number minus one.

## Using image name

Another way to specify the version for rollback is with the container definition's image value.  Here's the portion of the ecs task definition that you would look for:

    ...
    "container_definitions": [
      {
        "name": "web",
        "image": "tongueroo/demo-ufo:ufo-2018-06-21T15-03-52-ac60240",
        "cpu": 256,
    ...

You only need to specify enough for a match to be found.  Ufo searches the 30 most recent task definitions. So all of these would work:

    ufo rollback tongueroo/demo-ufo:ufo-2018-06-21T15-03-52-ac60240
    ufo rollback 2018-06-21T15-03-52
    ufo rollback ac60240


## Options

```
[--wait], [--no-wait]        # Wait for deployment to complete
                             # Default: true
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides .ufo/settings.yml.
```

