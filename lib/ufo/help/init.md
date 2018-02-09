Examples:

  ufo init --app=hi --image=tongueroo/hi

The app is that application name that you want to show up on the ECS dashboard.  It is strongly encourage to have the app name be a single word.

The image is the base portion of image name that will be pushed to the docker registry, ie: DockerHub or AWS ECR.  The image should not include the tag since the tag is generated upon a `ufo ship`.  For example:

  tongueroo/hi => tongueroo/hi:ufo-2018-02-08T21-04-02-3c86158

The generated `tongueroo/hi:ufo-2018-02-08T21-04-02-3c86158` image name gets pushed to the docker registry.
