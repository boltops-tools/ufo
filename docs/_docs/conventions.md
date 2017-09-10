---
title: Conventions
---

Ufo uses a set of naming conventions.  This helps enforce some best practices and also allows the ufo commands to be concise.  Ufo allows you to easily override or bypass the conventions if you need it.

### UFO_ENV to ECS Cluster Convention

By default, the ECS cluster value is the same as UFO_ENV's value.  So if `UFO_ENV=prod` then the ECS Cluster is prod and if `UFO_ENV=stag` then the ECS Cluster is stag.  You can easily override this convention by specifying the `--cluster` CLI option.  You can also override this behavior with [settings.yml]({% link _docs/settings.md %}) to spare you from having to type `--cluster` over and over.

### Service and Task Names Convention

Ufo assumes a convention that service\_name and the task\_name are the same. If you would like to override this convention then you can specify the task name.

```
ufo ship hi-web-prod --task my-task
```

This means that in the task_definition.rb you will also defined it with `my-task`.  For example:

```ruby
task_definition "my-task" do
  source "web" # this corresponds to the file in "ufo/templates/web.json.erb"
  variables(
    family: "my-task",
    ....
  )
end

```

### Web Role Convention

By convention, if the service has a container name web, you'll get prompted to create an ELB and specify a target group arn.  If you would like to name a service with the word "web" in it without having to use an ELB target group then you can use the `--no-target-group-prompt`.  Example:

```sh
ufo ship hi-web-prod --no-target-group-prompt
```

You can also bypass the prompt by specifying the target group arn as part of the command upfront. The ELB and target group must already exist.  The elb target group only gets associated when the service gets created for the first time.  If the service already exists then the `--target-group` parameter just gets ignored and the ECS task simply gets updated.  Example:

```bash
ufo ship hi-web-prod --target-group=arn:aws:elasticloadbalancing:us-east-1:12345689:targetgroup/hi-web-prod/12345
```

<a id="prev" class="btn btn-basic" href="{% link _docs/helpers.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/run-in-pieces.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
