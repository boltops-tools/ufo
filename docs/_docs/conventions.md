---
title: Conventions
nav_order: 18
---

Ufo uses a set of naming conventions.  This helps enforce some best practices and also allows the ufo commands to be concise.  You can override or bypass the conventions easily.

## UFO_ENV to ECS Cluster Convention

By default, the ECS cluster value is the same as UFO_ENV's value.  So if `UFO_ENV=production` then the ECS Cluster is `production` and if `UFO_ENV=development` then the ECS Cluster is `development`.  You can override this convention by specifying the `--cluster` CLI option.  You can also override this behavior with [settings.yml]({% link _docs/settings.md %}) to spare you from having to type `--cluster` repeatedly.

## Service and Task Names Convention

Ufo assumes a convention that service\_name and the task\_name are the same. If you would like to override this convention, then you can specify the task name.

```
ufo ship demo-web --task my-task
```

This means that in the task_definition.rb you will also define it with `my-task`.  For example:

```ruby
task_definition "my-task" do
  source "web" # this corresponds to the file in "ufo/templates/web.json.erb"
  variables(
    family: "my-task",
    ....
  )
end

```

## Web Service Load Balancer Convention

By convention, if the service has a container named "web", ufo will automatically create an ELB.  If you would like to name a service with the word "web" without an ELB, specify `--elb false`.  Example:

```sh
ufo ship demo-web --elb false
```

You can also use an existing ELB by specifying the target group arn as the value of the `--elb` option. Example:

```bash
ufo ship demo-web --elb arn:aws:elasticloadbalancing:us-east-1:12345689:targetgroup/demo-web/12345
```

{% include prev_next.md %}