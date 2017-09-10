---
title: Settings
---

The behavior of ufo can be configured via the `ufo/settings.yml` file.  A starter project `ufo/settings.yml` file is generated as part of the `ufo init` command. You can have multiple settings files. The options from the files get merged and respect the following precedence:

1. current folder - The current folder's `ufo/settings.yml` values take the highest precedence.
2. user - The user's `~/.ufo/settings.yml` values take the second highest precedence.
3. default - The [default settings](https://github.com/tongueroo/ufo/blob/master/lib/ufo/default/settings.yml) bundled with the tool takes the lowest precedence.

Let's take a look at an example `ufo/settings.yml`:

```yaml
image: tongueroo/hi
clean_keep: 30
ecr_keep: 30
aws_profile_ufo_env_map:
  default: prod
  # More examples:
  # aws_profile1: prod
  # aws_profile2: stag
  # aws_profile3: dev
ufo_env_cluster_map:
  default: prod
  # More examples:
  # aws_profile1: prod
  # aws_profile2: stag
  # aws_profile3: dev
```

The table below covers what each setting does:

Setting  | Description
------------- | -------------
`image`  | The `image` value is the name that ufo will use for the Docker image name to be built.  Only provide the basename part of the image name without the tag because ufo automatically generates the tag for you. For example, `tongueroo/hi` is correct and `tongueroo/hi:my-tag` is incorrect.
`aws_profile_ufo_env_map`  | Maps the `AWS_PROFILE` to the `UFO_ENV` value.
`ufo_env_cluster_map`  | Maps the `UFO_ENV` to an ECS cluster value.  This allows you to override the convention where the default cluster equals to `UFO_ENV`. value.  This is covered in detailed at [Conventions]({% link _docs/conventions.md %}).


### UFO_ENV to ECS Cluster Mapping

The `ufo_env_cluster_map` option allows you to override the [UFO_ENV to ECS Cluster Convention]({% link _docs/conventions.md %}).  Normally, the ECS cluster defaults to whatever UFO_ENV is set to.  For example, when `UFO_ENV=prod` the ECS Cluster is prod and when `UFO_ENV=stag` the ECS Cluster is stag.  This setting allows you to override this behavior so that you do not have to specify the `--cluster` CLI option repeatedly.  Let's go through an example:

By default:

```sh
UFO_ENV=prod ufo ship hi-web # cluster defaults to UFO_ENV which is prod
UFO_ENV=prod ufo ship hi-web --cluster prod # same as above
```

Override the convention and explicitly specify the `--cluster` option in the CLI.

```sh
UFO_ENV=prod ufo ship hi-web --cluster custom-cluster # override the default UFO_ENV TO cluster mapping
```

We can also override the convention with `settings.yml`:

```yaml
ufo_env_cluster_map:
  prod: custom-cluster
```

Because of the `ufo_env_cluster_map` setting, the `--cluster` CLI option is not longer required:

```sh
UFO_ENV=prod ufo ship hi-web # same as --cluster custom-cluster because of settings.yml
```

### AWS_PROFILE TO UFO_ENV Mapping

An interesting way to set `UFO_ENV` is with the `aws_profile_ufo_env_map` in `ufo/settings.yml`.  Given:

```yaml
aws_profile_ufo_env_map:
  default: dev
  my-prod-profile: prod
  my-stag-profile: stag
```

In this case, when you set `AWS_PROFILE` to switch AWS profiles, ufo picks this up and maps the `AWS_PROFILE` value to the specified `UFO_ENV` using the `aws_profile_ufo_env_map` lookup.  Example:

```sh
AWS_PROFILE=my-prod-profile => UFO_ENV=prod
AWS_PROFILE=my-stag-profile => UFO_ENV=stag
AWS_PROFILE=default => UFO_ENV=dev
AWS_PROFILE=whatever => UFO_ENV=dev
```

Notice how `AWS_PROFILE=whatever` results in `UFO_ENV=dev`.  This is because the `default: dev` map is specially treated. If you set the `default` map, this becomes the default value when the profile map is not specified in the rest of `ufo/settings.yml`.

This behavior prevents you from switching `AWS_PROFILE`s and then accidentally deploying a production based docker image to staging and vice versas because you forgot to also switch `LONO_ENV` to its respective environment.


<a id="prev" class="btn btn-basic" href="{% link _docs/ufo-help.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-env.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

