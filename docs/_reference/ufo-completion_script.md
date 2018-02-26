---
title: ufo completion_script
reference: true
---

## Usage

    ufo completion_script

## Description

Generates a script that can be eval to setup auto-completion.

To use, add the following to your ~/.bashrc or ~/.profile

    eval $(ufo completion_script)


## Options

```
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides ufo/settings.yml.
```

