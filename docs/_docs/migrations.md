---
title: Database Migrations
nav_order: 35
---

A common task is to run database migrations with newer code before deploying the code. This is easily achieved with the `ufo task` command. Here's an example:

```sh
ufo task demo-web -c bundle exec rake db:migrate
```

It is nice to wrap the commands in a wrapper script in case you have to do things like to load the environment.

```sh
ufo task demo-web -c bin/migrate
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

{% include prev_next.md %}