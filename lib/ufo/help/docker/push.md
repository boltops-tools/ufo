
The `ufo docker push` command pushes the most recent Docker image built by `ufo docker build` to a registry.  This command pushes a docker image up to the registry.  By default it pushes the last image that was built with `ufo docker build`.  To see what the image name is you can run `ufo docker name`. Example:

    ufo docker build # to build the image
    ufo docker name  # to see the image name
    ufo docker push  # push up the registry

You'll see that `ufo docker push` simply shells out and calls `docker push`:

    $ ufo docker push
    => docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/hi:ufo-2018-02-13T10-51-44-e0cc7be
    The push refers to a repository [123456789.dkr.ecr.us-east-1.amazonaws.com/hi]
    399c739c257d: Layer already exists
    ...
    Pushed 123456789.dkr.ecr.us-east-1.amazonaws.com/hi:ufo-2018-02-13T10-51-44-e0cc7be docker image. Took 1s.
    $

You can also push up a custom image by specifying the image name as the first parameter.

    ufo docker push my/image:tag

You could also use the `--push` flag as part of the `ufo docker build` command to achieve the same thing as `ufo docker push`. The `ufo docker push` command might be more intutitive.

    ufo docker build --push # same as above

## Docker Authorization

Note in order to push the image to a registry you will need to login into the registry.  If you are using DockerHub use the `docker login` command.  If you are using AWS ECR then, ufo will automatically try to authorize you and configure your `~/.docker/config.json`.  If can also use `aws ecr get-login` command.
