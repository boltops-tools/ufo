---
title: ufo docker clean
reference: true
---

## Usage

    ufo docker clean IMAGE_NAME

## Description

Cleans up old images.  Keeps a specified amount.

Ufo comes with a handy command to clean up old images that ufo generates. Ufo only deletes images from the docker daemon and does not remove any images from any registry.  To use it you pass the base portion of the image name to the command.

Say you currently have these images:

    tongueroo/hi:ufo-2016-10-15T19-29-06-88071f5
    tongueroo/hi:ufo-2016-10-16T19-29-06-88071f5
    tongueroo/hi:ufo-2016-10-17T19-29-06-88071f5
    tongueroo/hi:ufo-2016-10-18T19-29-06-88071f5

To clean them up and keep the 3 more recent:

    $ ufo docker clean tongueroo/hi
    Cleaning up docker images...
    Running: docker rmi tongueroo/hi:ufo-2016-10-15T19-29-06-88071f5

This will remove tongueroo/hi:ufo-2016-10-15T19-29-06-88071f5.

By default the clean command keeps the most 3 recent docker images. If you would like to override this setting you can use the `--keep` option. Example:

    ufo docker clean tongueroo/hi --keep 5


## Options

```
[--keep=N]                 
                           # Default: 3
[--tag-prefix=TAG_PREFIX]  
                           # Default: ufo
```

