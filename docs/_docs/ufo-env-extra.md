---
title: UFO_ENV_EXTRA
---

Ufo has an concept of extra environments. This is controlled by the `UFO_ENV_EXTRA` variable.  By setting `UFO_ENV_EXTRA` you can create additional ECS services with similar environments.

    ufo ship hi-web # creates a hi-web ecs service
    UFO_ENV_EXTRA=2 ufo ship hi-web # creates a hi-web-2 ecs service

The `UFO_ENV_EXTRA` can also be set by `ufo current` so you do not have to type it over.

    ufo current --env-extra 1

The precedence:

1. UFO_ENV_EXTRA - takes highest precedence
2. `.ufo/current` setting - takes lower precedence

<a id="prev" class="btn btn-basic" href="{% link _docs/params.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/variables.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
