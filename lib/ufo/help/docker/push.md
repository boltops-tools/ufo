This command pushes a docker image up to the registry.  By default it pushes the last image that was built with `ufo docker build`.  To see what the image name is you can run `ufo docker name`. Example:

  ufo docker build # to build the image
  ufo docker name  # to see the image name
  ufo docker push  # push up the registry

You can also push up a custom by specifying the image name with the `--image` option.

  ufo docker push --image my/image:tag
