---
title: ufo tasks
reference: true
---

## Usage

    ufo tasks SUBCOMMAND

## Description

task definition subcommands

## Examples

    ufo tasks build

Builds all the task defintiions.

Note all the existing ufo/output generated task defintions are wiped out.

## Subcommands

* [ufo tasks build]({% link _reference/ufo-tasks-build.md %}) - builds task definitions
* [ufo tasks register]({% link _reference/ufo-tasks-register.md %}) - register all built task definitions in ufo/output

## Options

```
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides ufo/settings.yml.
```

