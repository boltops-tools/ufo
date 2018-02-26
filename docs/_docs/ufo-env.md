---
title: UFO_ENV
---

Ufo's behavior is controlled by the `UFO_ENV` environment variable.  For example, the `UFO_ENV` variable is used to layer different ufo variable files together to make it easy to specify settings for different environments like production and development.  This is covered thoroughly in the [Variables]({% link _docs/variables.md %}) section.  `UFO_ENV` defaults to `development` when not set.

## Setting UFO_ENV

The `UFO_ENV` can be set in several ways:

1. At the CLI command invocation - This takes the highest precedence.
2. Exported as an environment variable to your shell - This takes the second highest precedence.
3. From the `aws_profiles` setting in your `settings.yml` file - This takes the lowest precedence.

## At the CLI Command

```sh
ufo ship hi-web --cluster production
```

## As an environment variable

```sh
export UFO_ENV=production
ufo ship hi-web
```

Most people will set `UFO_ENV` in their `~/.profile`.

## In ufo/settings.yml

The most interesting way to set `UFO_ENV` is with the `aws_profiles` setting in `.ufo/settings.yml`.  Let's say you have a `~/.ufo/settings.yml` with the following:

```yaml
development:
  aws_profiles:
    - my-dev-profile

production:
  aws_profiles:
    - my-prod-profile
```

In this case, when you set `AWS_PROFILE` to switch AWS profiles, ufo picks this up and maps the `AWS_PROFILE` value to the specified `UFO_ENV` using the `aws_profiles` lookup.  Example:

```sh
AWS_PROFILE=my-prod-profile => UFO_ENV=production
AWS_PROFILE=my-dev-profile => UFO_ENV=development
AWS_PROFILE=whatever => UFO_ENV=development # since there are no profiles that match
```

Notice how `AWS_PROFILE=whatever` results in `UFO_ENV=development`.  This is because there are not matching aws_profiles in the `settings.yml`.  More info on settings is available at [settings]({% link _docs/settings.md %}).

<a id="prev" class="btn btn-basic" href="{% link _docs/settings.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/variables.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
