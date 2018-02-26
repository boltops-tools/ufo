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

* [ufo tasks build]({% link _reference/ufo-tasks-build.md %}) - Build task definitions.
* [ufo tasks register]({% link _reference/ufo-tasks-register.md %}) - Register all built task definitions in `ufo/output` folder.

## Options

```
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides ufo/settings.yml.
```

