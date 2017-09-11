---
title: ufo ships
---

The `ufo ships` command allows you to deploy the *same* Docker image and task definition to multiple ECS services.  This is a very common pattern to have the same code base running on different roles.  For example, say you have an app with 3 roles:

1. web - serves web requests.
2. worker - processes background jobs.
3. clock - schedules background jobs.

Instead of using the [ufo ship]({% link _docs/ufo-ship.md %}) and build and deploying the code 3 times you can instead use `ufo ships`.  This will result in the *same* Docker image and *same* task definition being deployed to all 3 services.  Example usage:

```sh
ufo ships hi-web hi-worker hi-clock
```

### Shell expansion

Since the ECS service names are provided as a list you can shorten the command by using bash shell expansion 😁

```sh
ufo ships hi-{web,worker,clock}
```

If you're new to shell expansion, run this to understand why above works just as well:

```sh
$ echo hi-{web,worker,clock}
hi-web hi-worker hi-clock
```

### Overriding convention

As explained in detail in [Conventions]({% link _docs/conventions.md %}) the task definition and service name are the same by convention.  This convention also applies for each of the services being shipped in the list. The task definition and service names match for each of the services in the list.  If you would like to override the convention as part of the ships command then you use a special syntax. In the special syntax the service and task definition is separated by a colon.  Examples:

```sh
ufo ships hi-web-1:hi-web hi-clock-1 hi-worker-1
ufo ships hi-web-1:my-task hi-clock-1:another-task hi-worker-1:third-task
```

### ufo ships Options

The `ufo ships` and `ufo ship` command support the same options. The options are presented here again for convenience:

{% include ufo-ship-options.md %}

Note: The `--task` option is not used with the `ufo ships` command.

<a id="prev" class="btn btn-basic" href="{% link _docs/ufo-ship.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-scale.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

