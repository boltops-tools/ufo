---
title: ufo logs command
nav_order: 23
---

The ufo logs command will tail the logs of the ecs service if you are using the awslogs driver.

## Examples

    $ ufo logs demo-web
    2020-01-16 23:58:16 UTC 10.20.120.135 - - [16/Jan/2020:23:58:16 +0000] "GET / HTTP/1.1" 200 3 0.0003
    2020-01-16 23:58:16 UTC 10.20.120.135 - - [16/Jan/2020:23:58:16 UTC] "GET / HTTP/1.1" 200 3
    2020-01-16 23:58:16 UTC - -> /

## Current Set

If you have a current service name set.

    $ ufo current --service demo-web
    $ ufo logs # follow by default
    2020-01-16 23:58:16 UTC 10.20.120.135 - - [16/Jan/2020:23:58:16 +0000] "GET / HTTP/1.1" 200 3 0.0003
    2020-01-16 23:58:16 UTC 10.20.120.135 - - [16/Jan/2020:23:58:16 UTC] "GET / HTTP/1.1" 200 3
    2020-01-16 23:58:16 UTC - -> /

## Options

By default the logs follow and use the simple format without the log stream. Here's how adjust those options:

    ufo logs --no-follow
    ufo logs --format detailed # to show stream too

More info: [ufo logs reference]({% link _reference/ufo-logs.md %})

## awslog driver

The generated .ufo task definition defaults to the awslogs driver. If you need it, it looks like this:

```json
"logConfiguration": {
  "logDriver": "awslogs",
  "options": {
    "awslogs-group": "<%= @awslogs_group %>",
    "awslogs-region": "<%= @awslogs_region || 'us-east-1' %>",
    "awslogs-stream-prefix": "<%= @awslogs_stream_prefix %>"
  }
}
```

{% include prev_next.md %}
