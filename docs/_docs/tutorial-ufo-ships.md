---
title: ufo ships
---

You might have noticed in in the tutorial that the starter ufo folder that `ufo init` generates creates 3 task definitions for 3 services for a web, worker and clock role.  We can use the same `ufo ship` command to deploy to all 3 service roles like so:

```sh
ufo ship hi-web-stag
ufo ship hi-worker-stag
ufo ship hi-clock-stag
```

This will build Docker image and register task definition each time the command gets run.  It is a common pattern to actually want have the same code base running on all of these roles.  In this case, we want to use the *same* Docker image and *same* task definition for all 3 roles.  Ufo provides a `ufo ships` command for this exact situation.

### ufo ships

```sh
ufo ships hi-web-stag hi-worker-stag hi-clock-stag
```

You can check on the ECS console and should see something similar to this:

<img src="/img/tutorials/ecs-console-ufo-ships.png" class="doc-photo" />

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ufo-ship.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/commands.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

