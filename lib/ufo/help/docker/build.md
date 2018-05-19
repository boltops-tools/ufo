The `ufo docker build` builds a Docker image using the Dockerfile in the current project folder.  This simply is a wrapper command that shells out and calls the `docker` command.  We're use the [tongueroo/hi](https://github.com/tongueroo/hi) project and it's Dockerfile for demonstration.  Example:

    ufo docker build

You'll see that it calls:

    docker build -t tongueroo/hi:ufo-2017-06-11T22-18-03-a18aa30 -f Dockerfile .

You should see similar output (some of the output has been truncated for conciseness):

    $ ufo docker build
    Building docker image with:
      docker build -t tongueroo/hi:ufo-2017-06-11T22-18-03-a18aa30 -f Dockerfile .
    Sending build context to Docker daemon 734.2 kB
    Step 1 : FROM ruby:2.3.3
     ---> 0e1db669d557
    Step 2 : RUN apt-get update &&   apt-get install -y     build-essential     nodejs &&   rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get purge
     ---> Using cache
     ---> 931ace833716
    ...
    Step 7 : ADD . /app
     ---> fae2452e6c35
    Removing intermediate container 4c93f92a7fd8
    Step 8 : RUN bundle install --system
     ---> Running in f851b9cb7d27
    Using rake 12.0.0
    Using i18n 0.8.1
    ...
    Using web-console 2.3.0
    Bundle complete! 12 Gemfile dependencies, 56 gems now installed.
    Bundled gems are installed into /usr/local/bundle.
     ---> 194830c5c1a8
    ...
    Removing intermediate container 67545cd4cd09
    Step 11 : CMD bin/web
     ---> Running in b1b26e68d957
     ---> 8547bb48b21f
    Removing intermediate container b1b26e68d957
    Successfully built 8547bb48b21f
    Docker image tongueroo/hi:ufo-2017-06-11T22-18-03-a18aa30 built.  Took 33s.
    $

The docker image tag that is generated contains a useful timestamp and the current HEAD git sha of the project that you are on.

By default when you are running `ufo docker build` directly it does not push the docker image to the registry.  If you would like it to automaticaly push the built image to a registry at the end of the build use the `--push` flag.

    ufo docker build --push

You should see it being pushed at the end:

    Docker image tongueroo/hi:ufo-2017-06-11T22-22-32-a18aa30 built.  Took 34s.
    The push refers to a repository [docker.io/tongueroo/hi]
    ef375857f165: Pushed
    4d791d7cde66: Pushed
    277ff31e79b4: Layer already exists
    a361a4de05df: Layer already exists
    ufo-2017-06-11T22-22-32-a18aa30: digest: sha256:c5385a5084e87643bd943eb120e110321c59e8acd30736ba7b5223eb1143baa8 size: 3464
    Pushed tongueroo/hi:ufo-2017-06-11T22-22-32-a18aa30 docker image. Took 9s.

Note in order to push the image to a registry you will need to login into the registry.  If you are using DockerHub use the `docker login` command.  If you are using AWS ECR then you can use the `aws ecr get-login` command.

## Docker Build Options

You can specify docker build options with the `UFO_DOCKER_BUILD_OPTIONS` environment variable.  Example:

    $ UFO_DOCKER_BUILD_OPTIONS="--build-arg RAILS_ENV=production" ufo docker build
    Building docker image with:
      docker build --build-arg RAILS_ENV=production -t tongueroo/hi:ufo-2018-05-19T11-52-16-6714713 -f Dockerfile .
    ...
    Docker image tongueroo/hi:ufo-2018-05-19T11-52-16-6714713 built.  Took 2s.
