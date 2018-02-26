---
title: ufo docker name
reference: true
---

## Usage

    ufo docker name

## Description

displays the full docker image with tag that was last generated.

This command fetches the last name that was generated when `docker build` was ran internally by `ufo docker build`.  You can use it after you have built a docker image with `ufo docker build`.

## Examples

    ufo docker build # stores the docker image name in the .ufo/data folder
    ufo docker name  # fetches image name from .ufo/data folder

An example image name would look something like this: tongueroo/hi:ufo-2018-02-15T19-29-06-88071f5

Note, the .ufo/data folder is an internal data folder and it's structure can change in future releases.

If you want to generate a brand new name for whatever purpose, you can use the `--generate` flag.  The generate does not write to the `.ufo/data` folder.  It only generates a fresh name to stdout.  If you run it multiple times, it will generate new names.  You can notice this by seeing that the timestamp will always update. ## Examples

    ufo docker name --generate  # example: tongueroo/hi:ufo-2018-02-15T10-00-00-88071f5
    ufo docker name --generate  # example: tongueroo/hi:ufo-2018-02-15T10-00-08-88071f5
    ufo docker name --generate  # example: tongueroo/hi:ufo-2018-02-15T10-00-16-88071f5


## Options

```
[--generate], [--no-generate]  # Generate a name without storing it
```

