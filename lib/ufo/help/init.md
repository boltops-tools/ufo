Examples:

  ufo init --app=hi --image=tongueroo/hi

The app is that application name that you want to show up on the ECS dashboard.  It is strongly encourage to have the app name be a single word.

The image is the base portion of image name that will be pushed to the docker registry, ie: DockerHub or AWS ECR.  The image should not include the tag since the tag is generated upon a `ufo ship`.  So the image name of tongueroo/hi results in an image name of tongueroo/hi:[timestamp] that will be pushed to the docker registry.
