---
title: ufo docker clean
---

Ufo comes with a handy command to clean up old images that ufo generates. Ufo only deletes images from the docker daemon and does not remove any images from any registry.  To use it you pass the base portion of the image name to the command. Example:

```sh
ufo docker clean tongueroo/hi
```

Here is some example output of the commmand:

```sh
Cleaning up docker images...
Running: docker rmi tongueroo/hi:ufo-2017-06-12T12-14-22-a18aa30 tongueroo/hi:ufo-2017-06-12T12-12-05-a18aa30
```

By default the clean command keeps the most 3 recent docker images. If you would like to override this setting you can use the `--keep` option. Example:

```sh
ufo docker clean tongueroo/hi --keep 5
```
