---
title: Settings Cluster
short_title: Cluster
categories: settings
nav_order: 15
---

Normally, the ECS cluster defaults to whatever UFO_ENV is set to by [convention]({% link _docs/conventions.md %}).  For example, when `UFO_ENV=production` the ECS Cluster is `production` and when `UFO_ENV=development` the ECS Cluster is `development`.  There are several ways to override this behavior. Let's go through some examples.

## CLI Override

By default, these are all the same:

```sh
ufo ship demo-web
UFO_ENV=development ufo ship demo-web # same
UFO_ENV=development ufo ship demo-web --cluster development # same
```

If you use a specific `UFO_ENV=production`, these are the same

```
UFO_ENV=production ufo ship demo-web
UFO_ENV=production ufo ship demo-web --cluster production # same
```

Override the convention by explicitly specifying the `--cluster` option in the CLI.

```sh
ufo ship demo-web --cluster custom-cluster # override the cluster
UFO_ENV=production ufo ship demo-web --cluster production-cluster # override the cluster
```

The cavaet is that you must remember to specify `--cluster`.  A wrapper `bin/deploy` script could be useful here.

## Environment Cluster Setting

If you don't want to specify the `--cluster` option in the command repeatedly, you can configure the cluster based on the the UFO_ENV.  Setting the `cluster` option in the `settings.yml` file:

```yaml
development:
  cluster: dev

production:
  cluster: prod
```

## Service Cluster Setting

Another interesting way of specifying the cluster to use is with the `service_cluster` option.  The `service_cluster` option takes a Hash value. Here's an example:

```yaml
base:
  service_cluster:
    demo-web: web-fleet
    demo-worker: worker-fleet
```

In this example, ufo will deploy the demo-web service to the web-fleet ECS cluster and the demo-worker service to the worker-fleet ECS cluster.

Also since the service_cluster is configured in the base section, it is used for all `UFO_ENV=development`, `UFO_ENV=production`, etc.

## Precendence

The precedence of the settings from highest to lowest is:

* cli option
* service_cluster service specific setting
* cluster environment setting
* UFO_ENV default convention

{% include prev_next.md %}