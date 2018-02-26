---
title: ufo docker clean
reference: true
---

## Usage

    ufo docker clean IMAGE_NAME

## Description

Cleans up old images.  Keeps a specified amount.

## Examples

Say you currently have these images:

  * tongueroo/hi:ufo-2016-10-15T19-29-06-88071f5
  * tongueroo/hi:ufo-2016-10-16T19-29-06-88071f5
  * tongueroo/hi:ufo-2016-10-17T19-29-06-88071f5
  * tongueroo/hi:ufo-2016-10-18T19-29-06-88071f5

To clean them up and keep the 3 more recent:

    ufo docker clean tongueroo/hi

This will remove tongueroo/hi:ufo-2016-10-15T19-29-06-88071f5.


## Options

```
[--keep=N]                 
                           # Default: 3
[--tag-prefix=TAG_PREFIX]  
                           # Default: ufo
```

