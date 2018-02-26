---
title: ufo task
reference: true
---

## Usage

    ufo task TASK_DEFINITION

## Description

Run a one-time task.

## Examples

To run a one time task with ECS:

    ufo task hi-migrate

You can also override the command used by the Docker container in the task definitions via command.

    ufo task hi-web --command bin/migrate
    ufo task hi-web --command bin/with_env bundle exec rake db:migrate:redo VERSION=xxx


## Options

```
[--docker], [--no-docker]    # Enable docker build and push
                             # Default: true
[--command=one two three]    # Override the command used for the container
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides ufo/settings.yml.
```

