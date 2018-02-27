---
title: ufo completion
reference: true
---

## Usage

    ufo completion *PARAMS

## Description

Prints words for auto-completion.

Example:

    ufo completion

Prints words for TAB auto-completion.

## Examples

    ufo completion
    ufo completion ship
    ufo completion docker

To enable, TAB auto-completion add the following to your profile:

    eval $(ufo completion_script)

Auto-completion example usage:

    ufo [TAB]
    ufo ship [TAB]
    ufo docker build [TAB]
    ufo docker build --[TAB]


## Options

```
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides ufo/settings.yml.
```

