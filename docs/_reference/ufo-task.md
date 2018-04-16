---
title: ufo task
reference: true
---

## Usage

    ufo task TASK_DEFINITION

## Description

Run a one-time task.

## Examples

You can use the `--command` or `-c` option to override the Docker container command.

    ufo task hi-migrate # default command
    ufo task hi-web --command bin/migrate
    ufo task hi-web --command bin/with_env bundle exec rake db:migrate:redo VERSION=xxx
    ufo task hi-web -c uptime
    ufo task hi-web -c pwd


## Options

```
    [--docker], [--no-docker]    # Enable docker build and push
                                 # Default: true
c, [--command=one two three]     # Override the command used for the container
    [--verbose], [--no-verbose]  
    [--mute], [--no-mute]        
    [--noop], [--no-noop]        
    [--cluster=CLUSTER]          # Cluster.  Overrides ufo/settings.yml.
```

