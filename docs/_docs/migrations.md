---
title: Database Migrations
---

A common task is to run database migrations with newer code before deploying the code. This is easily achieved with the `ufo task` command. Here's an example:

```sh
ufo task hi-web --command bundle exec rake db:migrate
```

It nice to wrap the commands in a wrapper script in case you have to do things like the load the environment.

```sh
ufo task hi-web --command bin/migrate
```

The `bin/migrate` script can look like this:

```bash
#!/bin/bash
bundle exec rake db:migrate
```

The `ufo task` command is generalized so you can run any one-off task. It is not just limited to running migrations. The `ufo task` command performs the following:

1. Builds the docker image and pushes it to a registry
2. Registers the ECS Task definition
3. Runs a one-off ECS Task

<a id="prev" class="btn btn-basic" href="{% link _docs/single-task.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/automated-cleanup.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
