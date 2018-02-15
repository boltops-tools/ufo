---
title: Settings
---

The behavior of ufo can be configured with a `settings.yml` file.  A starter project `.ufo/settings.yml` file is generated as part of the `ufo init` command. You can have multiple settings files. The options from the files get merged and respected in the following precedence:

1. current folder - The current folder's `.ufo/settings.yml` values take the highest precedence.
2. user - The user's `~/.ufo/settings.yml` values take the second highest precedence.
3. default - The [default settings](https://github.com/tongueroo/ufo/blob/master/lib/ufo/default/settings.yml) bundled with the tool takes the lowest precedence.

Let's take a look at an example `settings.yml`:

```yaml
base:
  image: tongueroo/hi
  # clean_keep: 30 # cleans up docker images on your docker server.
  # ecr_keep: 30 # cleans up images on ECR and keeps this remaining amount. Defaults to keep all.
  # defaults when an new ECS service is created by ufo ship
  new_service:
    maximum_percent: 200
    minimum_healthy_percent: 100
    desired_count: 1

development:
  # cluster: dev # uncomment if you want the cluster name be other than the default
                 # the default is to match UFO_ENV.  So UFO_ENV=development means the ECS
                 # cluster will be name development
  # When you have AWS_PROFILE set to one of these values, ufo will switch to the desired
  # environment. This prevents you from switching AWS_PROFILE, forgetting to
  # also switch UFO_ENV, and accidentally deploying to production vs development.
  # aws_profiles:
  #   - dev_profile1
  #   - dev_profile2

production:
  # cluster: prod
  # aws_profiles:
  #   - prod_profile
```

The table below covers each setting:

Setting  | Description
------------- | -------------
`image`  | The `image` value is the name that ufo will use for the Docker image name to be built.  Only provide the basename part of the image name without the tag because ufo automatically generates the tag for you. For example, `tongueroo/hi` is correct and `tongueroo/hi:my-tag` is incorrect.
`clean_keep`  | Docker images generated from ufo are cleaned up automatically for you at the end of `ufo ship`. This controls how many docker images to keep around. The default is 3.
`ecr_keep`  | If you are using AWS ECR, then the ECR images can also be automatically cleaned up at the end of `ufo ship`. By default this is set to `nil` and all AWS ECR are kept.
`cluster`  | By convention, the ECS cluster that ufo deploys to matches the `UFO_ENV`. If `UFO=development`, then `ufo ship` deploys to the `development` ECS cluster. This is option overrides this convetion.
`aws_profiles`  | If you have the `AWS_PROFILE` environment variable set, this will ensure that you are deploying the right `UFO_ENV` to the right AWS

Maps the `UFO_ENV` to an ECS cluster value.  This allows you to override the convention where the default cluster equals to `UFO_ENV`. value.  This is covered in detailed at [Conventions]({% link _docs/conventions.md %}).


### ECS Cluster Convention

Normally, the ECS cluster defaults to whatever UFO_ENV is set to by [convention]({% link _docs/conventions.md %}).  For example, when `UFO_ENV=production` the ECS Cluster is `production` and when `UFO_ENV=development` the ECS Cluster is `development`.  There are several ways to override this behavior. Let's go through an example:

By default, these are all the same:

```sh
ufo ship hi-web
UFO_ENV=development ufo ship hi-web # same
UFO_ENV=development ufo ship hi-web --cluster development # same
```

If you use a specific `UFO_ENV=production`, these are the same

```
UFO_ENV=production ufo ship hi-web
UFO_ENV=production ufo ship hi-web --cluster production # same
```

Override the convention by explicitly specifying the `--cluster` option in the CLI.

```sh
ufo ship hi-web --cluster custom-cluster # override the cluster
UFO_ENV=production ufo ship hi-web --cluster production-cluster # override the cluster
```

Override the convention by setting the cluster option in the `settings.yml` file, so you won't have to specify the `--cluster` option in the command repeatedly.

```yaml
development:
  cluster: dev

production:
  cluster: prod
```


### AWS_PROFILE support

An interesting option is `aws_profiles`.  Here's an example:

```yaml
development:
  aws_profiles:
    - dev-profile1
    - dev-profile2

production:
  aws_profiles:
    - prod-profile
```

In this case, when you set the environment variable `AWS_PROFILE` to switch AWS profiles in your shell, ufo picks this up and maps the `AWS_PROFILE` value to the specified `UFO_ENV` using the `aws_profiles` option.  Example:

```sh
AWS_PROFILE=dev-profile1 => UFO_ENV=development
AWS_PROFILE=dev-profile2 => UFO_ENV=development
AWS_PROFILE=prod-profile => UFO_ENV=production
```

This behavior prevents you from switching `AWS_PROFILE`s and then accidentally deploying a production based docker image to development and vice versas because you forgot to also switch `UFO_ENV` to its respective environment.

<a id="prev" class="btn btn-basic" href="{% link _docs/ufo-help.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-env.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

