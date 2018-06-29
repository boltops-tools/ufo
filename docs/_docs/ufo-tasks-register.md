---
title: ufo tasks register
---

The `ufo tasks register` command registers all the generated task definitions in `output/` to AWS ECS. Let's run it:

```sh
ufo tasks register
```

You should see something similiar to this:

```sh
demo-clock task definition registered.
demo-web task definition registered.
demo-worker task definition registered.
```

You can verify that the task definitions have been registered properly by viewing the AWS ECS Console Task Definitions page.  You should see something similar to this:

<img src="/img/tutorials/ecs-console-task-definitions.png" class="doc-photo" />

