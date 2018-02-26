The docker cache task builds a docker image using the Dockerfile.base file and
updates the FROM Dockerfile image with the generated image from Dockerfile.base.

## Examples

  ufo docker base
  ufo docker base --no-push # do not push the image to the registry

Docker image tongueroo/hi:base-2016-10-21T15-50-57-88071f5 built.
