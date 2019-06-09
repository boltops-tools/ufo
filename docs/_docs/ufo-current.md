---
title: Ufo Current
nav_order: 22
---

## service

There's a handy way to shorten ufo commands by setting the current service.  Example:

    ufo ship demo-web # normal usage
    ufo current --service demo-web
    ufo ship # no longer have to type: demo-web

To view the current settings run `ufo current` with no options.

    $ ufo current
    Current env_extra: 1
    Current service: demo-web

Setting the current service helps shorten other commands also:

    ufo cancel
    ufo deploy
    ufo destroy
    ufo ps
    ufo releases
    ufo resources
    ufo rollback VERSION
    ufo scale COUNT
    ufo ship

## UFO_ENV_EXTRA

The UFO_ENV_EXTRA env variable allows you create multiple environments with of the same services quickly.  More info about is is detailed at [ufo-env-extra]({% link _docs/ufo-env-extra.md %}).  You can also set a current UFO_ENV_EXTRA with the `--env-extra` option.

    ufo current --env-extra 1

## services

The `ufo ships` commands builds one Docker image and deploys them to multiple ECS services, so it usually takes a list of services like so:

    ufo ships demo-web demo-worker demo-clock

This can be shorten with with current also.

    ufo current --services demo-web demo-worker demo-clock
    ufo ships

{% include prev_next.md %}