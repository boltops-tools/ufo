---
title: ufo logs
reference: true
---

## Usage

    ufo logs

## Description

Prints out logs

## Examples

    ufo logs demo-web

If you have a current service name set.

    ufo current --service demo-web
    ufo logs # follow by default
    ufo logs --no-follow
    ufo logs --format detailed # to show stream too


## Options

```
[--follow], [--no-follow]          #  Whether to continuously poll for new logs. To exit from this mode, use Control-C.
                                   # Default: true
[--since=SINCE]                    # From what time to begin displaying logs.  By default, logs will be displayed starting from 1 minutes in the past. The value provided can be an ISO 8601 timestamp or a relative time.
[--format=FORMAT]                  # The format to display the logs. IE: detailed or short.  With detailed, the log stream name is also shown.
                                   # Default: simple
[--filter-pattern=FILTER_PATTERN]  # The filter pattern to use. If not provided, all the events are matched
[--verbose], [--no-verbose]        
[--mute], [--no-mute]              
[--noop], [--no-noop]              
[--cluster=CLUSTER]                # Cluster.  Overrides .ufo/settings.yml.
```

