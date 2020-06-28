---
title: UFO_ENV
nav_order: 23
---

Ufo's behavior is controlled by the `UFO_ENV` environment variable.  For example, the `UFO_ENV` variable is used to layer different ufo variable files together to make it easy to specify settings for different environments like production and development.  This is covered thoroughly in the [Variables]({% link _docs/variables.md %}) section.  `UFO_ENV` defaults to `development` when not set.

## Setting UFO_ENV

The `UFO_ENV` can be set in several ways:

1. Exported as an environment variable to your shell - This takes the second highest precedence.
2. From the `aws_profiles` setting in your `settings.yml` file - This takes the lowest precedence.

## As an environment variable

```sh
export UFO_ENV=production
ufo ship demo-web
```

You can set `UFO_ENV` in your `~/.profile`.

## In .ufo/settings.yml

The most interesting way to set `UFO_ENV` is with the `aws_profiles` setting in `.ufo/settings.yml`.  Let's say you have a `~/.ufo/settings.yml` with the following:

```yaml
development:
  aws_profile: my-dev-profile

production:
  aws_profile: my-prod-profile
```

In this case, when you set `AWS_PROFILE` to switch AWS profiles, ufo picks this up and maps the `AWS_PROFILE` value to the specified `UFO_ENV` using the `aws_profiles` lookup.  Example:

```sh
AWS_PROFILE=my-prod-profile => UFO_ENV=production
AWS_PROFILE=my-dev-profile => UFO_ENV=development
AWS_PROFILE=whatever => UFO_ENV=development # since there are no profiles that match
```

Notice how `AWS_PROFILE=whatever` results in `UFO_ENV=development`.  This is because there are no matching aws_profiles in the `settings.yml`.  More info on settings is available at [settings]({% link _docs/settings.md %}).

{% include prev_next.md %}
