---
title: Dynamic Dockerfile.erb
nav_order: 33
---

Sometimes you may need a little more dynamic control of your Dockerfile. For these cases, ufo supports dynamically creating a Dockerfile from a Dockerfile.erb.  If Dockerfile.erb exists, ufo uses it to generate a Dockerfile as a part of the build process.  These means that you should update the source Dockerfile.erb instead, as the Dockerfile will be overwritten.  If Dockerfile.erb does not exist, then ufo will use the Dockerfile instead.

## Example

The Dockerfile.erb has access to variables defined in `dockerfile_variables.yml`. The variables should be defined underneath a `UFO_ENV` key. Examples:

.ufo/settings/dockerfile_variables.yml:

```yaml
---
development:
  base_image: 112233445566.dkr.ecr.us-west-1.amazonaws.com/demo/sinatr:base-2019-06-10T03-22-34-f91cdd350
production:
  base_image: 778899001122.dkr.ecr.us-west-1.amazonaws.com/demo/sinatr:base-2019-06-10T03-23-34-abccddxzy
```

Note, the `base_image` key is automatically updated by [ufo docker base](http://ufoships.com/reference/ufo-docker-base/) when Dockerfile.erb exists.

Here's what the `Dockerfile.erb` looks like:

```Dockerfile
FROM <%= @base_image %>
# ...
CMD ["bin/web"]
```

When `UFO_ENV=production`, it'll produce the following.

Dockerfile:

```Dockerfile
FROM 778899001122.dkr.ecr.us-west-1.amazonaws.com/demo/sinatr:base-2019-06-10T03-23-34-abccddxzy
# ...
CMD ["bin/web"]
```

The above example demonstrates a good use-case. You may want a different FROM statement in your Dockerfile on a per-environment basis.  In this case, we're using different ECR repositories from different AWS accounts for development vs. production. The FROM statement changes based on which AWS account you're using.

## General Steps

The general steps are:

1. Create a Dockerfile.erb with `<%= @base_image %>`
2. Run: `ufo docker base` to generate `dockerfile_variables.yml`
3. Run: `ufo docker build` to build a Dockerfile. Note, the `ufo ship` command also builds the Dockerfile.

Remember when using the Dockerfile.erb, the Dockerfile is generated and overwritten. So you should update the Dockerfile.erb.

## Build Args

Why not use [build args](https://www.jeffgeerling.com/blog/2017/use-arg-dockerfile-dynamic-image-specification)?

Ufo uses a YAML file so users will not have to remember to provide the build arg. It is also easy to update the `dockerfile_variables.yml` with the `ufo docker base` command.

{% include prev_next.md %}
