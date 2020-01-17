---
title: Settings AWS_PROFILE
short_title: AWS Profile
categories: settings
nav_order: 13
---

## AWS_PROFILE support

An interesting option is `aws_profile`.  Here's an example:

```yaml
development:
  aws_profile: dev_profile

production:
  aws_profile: prod_profile
```

This provides a way to tightly bind `UFO_ENV` to `AWS_PROFILE`.  This prevents you from forgetting to switch your `UFO_ENV` when switching your `AWS_PROFILE` thereby accidentally launching a stack in the wrong environment.


AWS_PROFILE | UFO_ENV | Notes
--- | --- | ---
dev_profile | development
prod_profile | production
whatever | development | default since whatever is not found in settings.yml

The binding is two-way. So:

    UFO_ENV=production ufo ship # will deploy to the AWS_PROFILE=prod_profile
    AWS_PROFILE=prod_profile ufo ship # will deploy to the UFO_ENV=production

This behavior prevents you from switching `AWS_PROFILE`s, forgetting to switch `UFO_ENV` and then accidentally deploying a production based docker image to development and vice versa because you forgot to also switch `UFO_ENV` to its respective environment.

{% include prev_next.md %}
