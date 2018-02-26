---
title: ufo completion
reference: true
---

## Usage

    ufo completion *PARAMS

## Description

prints words for auto-completion

Example:

    ufo completion

Prints words for TAB auto-completion.

Examples:

    ufo completion
    ufo completion hello
    ufo completion hello name

To enable, TAB auto-completion add the following to your profile:

    eval $(ufo completion_script)

Auto-completion example usage:

    ufo [TAB]
    ufo hello [TAB]
    ufo hello name [TAB]
    ufo hello name --[TAB]


## Options

```
[--verbose], [--no-verbose]  
[--mute], [--no-mute]        
[--noop], [--no-noop]        
[--cluster=CLUSTER]          # Cluster.  Overrides ufo/settings.yml.
```

