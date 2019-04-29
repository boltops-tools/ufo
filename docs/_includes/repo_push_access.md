## Repo Push Access

The quick start example pushes the Docker image to a Docker repo that you have access to. This repo could be your own Dockerhub account or ECR repo.  You can control the setting with the `--image` option.  Example:

    ufo init --image=yourusername/yourrepo # use your own Dockerhub account

Also, if you are using ECR instead, you can specify an ECR repo with the `--image` option.  Example:

    ufo init --image 123456789012.dkr.ecr.us-west-2.amazonaws.com/myimage

For more info, refer to the [ufo init](http://ufoships.com/reference/ufo-init/) reference docs.
