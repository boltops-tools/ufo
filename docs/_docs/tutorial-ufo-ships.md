---
title: Deploy Multiple Apps
nav_order: 9
---

You might have noticed in the tutorial that the generated starter .ufo folder contains 3 task definitions a `web`, `worker` and `clock` role.  This is a common pattern.  The web process handles web traffic, the worker process handles background job processing that would be too slow and potentially block web requests, and a clock process is typically used to schedule recurring jobs.

These processes typically use the same codebase and same docker image, but have slightly different run time settings.  The docker run command for a web process could be [puma](http://puma.io/) and the command for a worker process could be [sidekiq](http://sidekiq.org/).  Environment variables are also sometimes different.  The important key is that the same docker image is used for all 3 services but the task definition for each service is slightly different.

While we can use the `ufo ship` command to deploy to all 3 service roles individually like so:

```sh
ufo ship demo-web
ufo ship demo-worker
ufo ship demo-clock
```

This would build a new Docker image for each process.  We actually want have the same docker image running on all of these roles.  In this case where we want to use the *same* Docker image for all 3 roles, ufo provides a `ufo ships` command.

## ufo ships

```sh
ufo ships demo-web demo-worker demo-clock
```

You can check on the ECS console and should see something similar to this:

<img src="/img/tutorials/ecs-console-ufo-ships.png" class="doc-photo" />

You can shorten the command by taking advantage of shell expansion:

```sh
ufo ships demo-{web,worker,clock}
```

In the case of the `ufo ships` command the `--wait` option defaults to false so that all the specified ECS services update in parallel.  You can check on the status of the update on the CloudFormation console.

{% include prev_next.md %}