---
title: Settings
---

The behavior of ufo can be configured via the `ufo/settings.yml` file.  A starter `settings.yml` file is generated as part of the `ufo init` command. A lot of these settings are default options so you do not have to type out these options repeatedly for some of the ufo commands. Let's cover the available settings in an example `settings.yml` that we've modified:

```yaml
image: tongueroo/hi
clean_keep: 30
ecr_keep: 30
service_cluster:
  default: stag # default cluster
  hi-web-stag: stag
  hi-clock-stag: blue
  hi-worker-stag: anothercluster
```

### Docker image name

The `image` value is the name that ufo will use for the Docker image name to be built.  Only provide the basename part of the image name without the tag. For example, `tongueroo/hi` is correct and `tongueroo/hi:my-tag` is incorrect.

### ECS Cluster for Service

The `service_cluster` mapping provides a way to set default "service-to-cluster" mappings so that you do not have to specify the `--cluster` repeatedly.  This is very helpful. For example:

```sh
ufo ship hi-web-stag --cluster stag
ufo ship hi-web-stag # same as above because it is configured in ufo/settings.yml
ufo ship hi-web-stag --cluster special-cluster # overrides the default setting in `ufo/settings.yml`
```

Also, with this `settings.yml`:

```sh
ufo ship hi-clock-stag # deploys to the ECS cluster named blue
```

### ECR Cleanup

Ufo can be configured to automatically clean old images from the ECR registry after the deploy completes.

```yaml
ecr_keep: 30
```

### Docker Cleanup

Ufo can be configured to automatically clean old Docker images.

```yaml
docker_keep: 30
```

<a id="prev" class="btn btn-basic" href="{% link _docs/ufo-help.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/helpers.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

