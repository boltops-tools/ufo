---
title: UFO_ENV_EXTRA
nav_order: 22
---

<div class="video-box"><div class="video-container"><iframe src="https://www.youtube.com/embed/UVQuwQGToYE" frameborder="0" allowfullscreen=""></iframe></div></div>

Ufo has an concept of extra environments. This is controlled by the `UFO_ENV_EXTRA` variable.  By setting `UFO_ENV_EXTRA` you can create additional identical ECS services or environments.

    ufo ship demo-web # creates a demo-web ecs service
    UFO_ENV_EXTRA=2 ufo ship demo-web # creates a demo-web-2 ecs service

The `UFO_ENV_EXTRA` can also be set with `ufo current` so you do not have to type it over.

    ufo current --env-extra 1

The precedence:

1. UFO_ENV_EXTRA - takes highest precedence
2. `.ufo/current` env-extra setting - takes lower precedence

{% include prev_next.md %}
