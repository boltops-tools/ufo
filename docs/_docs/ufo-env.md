---
title: UFO_ENV
---

Ufo's behavior is controlled by the `UFO_ENV` environment variable.  For example, the `UFO_ENV` variable is used to layer different ufo variable files together to make it easy to specify settings for different environments like production and staging.  This is covered thoroughly in the [Variables]({% link _docs/variables.md %}) section.  `UFO_ENV` defaults to `prod` when not set.

### Setting UFO_ENV

The `UFO_ENV` can be set easily in several ways:

1. At the CLI command invocation - This takes the highest precedence.
2. Exported as an environment variable to your shell - This takes the second highest precedence.
3. As a `aws_profile_ufo_env_map` value in your `ufo/settings.yml` file - This takes the lowest precedence.

### At the CLI Command

```sh
UFO_ENV=production ufo ship hi-web --cluster prod
```

### As an environment variable

```sh
export UFO_ENV=production
ufo ship hi-web --cluster prod
```

Most people will set `UFO_ENV` in their `~/.profile`.

### In ufo/settings.yml

The most interesting way to set `UFO_ENV` is with the `aws_profile_ufo_env_map` in `ufo/settings.yml`.  Let's say you have a `~/.ufo/settings.yml` with the following:

```yaml
aws_profile_ufo_env_map:
  default: development
  my-prod-profile: production
  my-stag-profile: staging
```

In this case, when you set `AWS_PROFILE` to switch AWS profiles, ufo picks this up and maps the `AWS_PROFILE` value to the specified `UFO_ENV` using the `aws_profile_ufo_env_map` lookup.  Example:

```sh
AWS_PROFILE=my-prod-profile => UFO_ENV=production
AWS_PROFILE=my-stag-profile => UFO_ENV=staging
AWS_PROFILE=default => UFO_ENV=development
AWS_PROFILE=whatever => UFO_ENV=development
```

Notice how `AWS_PROFILE=whatever` results in `UFO_ENV=development`.  This is because the `default: development` map is specially treated. If you set the `default` map, this becomes the default value when the profile map is not specified in the rest of `ufo/settings.yml`.  More info on settings is available at [settings]({% link _docs/settings.md %}).

<a id="prev" class="btn btn-basic" href="{% link _docs/settings.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/variables.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
