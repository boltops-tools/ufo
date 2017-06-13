---
title: ufo tasks register
---

The `ufo tasks register` command registers all the generated task definitions in `output/` to AWS ECS. Let's run it:

```sh
ufo ecs register
```

You should see something similiar to this:

```sh
hi-clock-stag task definition registered.
hi-web-stag task definition registered.
hi-worker-stag task definition registered.
```

You can verify that the task definitions have been registered properly by viewing the AWS ECS Console Task Definitions page.  You should see something similar to this:

<img src="/img/tutorials/ecs-console-task-definitions.png" class="doc-photo" />

<a id="prev" class="btn btn-basic" href="{% link _docs/ufo-tasks-build.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-help.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

