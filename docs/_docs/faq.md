---
title: FAQ
---

**Q: Is AWS ECS Fargate supported?**

Yes, Fargate is supported.  To use ufo with Fargate, you will need to adjust the template in `.ufo/templates` to use a structure support by Fargate.  There are 2 key items to adjust:

1. The task definition json. Notably, it has the `requiresCompatibilities`, `networkMode`, and `executionRoleArn` attributes. It also moves the `cpu` and `memory` outside of the `containerDefinitions` attributes to the root as top-level attributes. For details on how to adjust the task definition refer to [Task Definitions]({% link _docs/tutorial-ufo-tasks-build.md %}).
2. The params that get sent to the `create_service` or  `run_task` api methods. For details on how to adjust the params refer to [Params]({% link _docs/params.md %})

If it's a brand new project, you can use `ufo init` with the `--launch-type fargate` option and it will generate a starter JSON file that has the right Fargate structure. More info is available at [ufo init reference](/reference/ufo-init/#fargate-support).

**Q: Can I tell ufo to use specific docker build options?**

Yes, you can do this with the environment variable `UFO_DOCKER_BUILD_OPTIONS`.  Example:

```
$ UFO_DOCKER_BUILD_OPTIONS="--build-arg RAILS_ENV=production" ufo docker build
Building docker image with:
  docker build --build-arg RAILS_ENV=production -t tongueroo/hi:ufo-2018-05-19T11-52-16-6714713 -f Dockerfile .
...
Docker image tongueroo/hi:ufo-2018-05-19T11-52-16-6714713 built.  Took 2s.
```

---

**Q: Can you tell ufo to use a custom user-defined Docker tag name?**

In short, no. There's some image cleanup logic that relies on the specific naming convention.  However, you can re-tag the build docker image with another tag after ufo is done building the image.  The key is using the `ufo docker name` command to get the last docker image name that was built by ufo. Example:

```
$ ufo docker build
$ ufo docker name
tongueroo/hi:ufo-2018-05-19T11-41-06-6714713
$ docker tag $(ufo docker name) hi:mytag
$ docker images | grep hi
hi                                                     mytag                              5b01e38bd060        3 minutes ago       955MB
tongueroo/hi                                           ufo-2018-05-19T11-41-06-6714713    5b01e38bd060        3 minutes ago       955MB
$ docker push hi:mytag
```

---

**Q: What's the difference between ufo vs ecs-deploy?**

Some differences:

* ecs-deploy is implemented in bash
* ufo is implemented in ruby
* ecs-deploy is a simpler, which could work better for you. It’s nice that it’s one bash script.

ufo does 3 things:

1. Builds and pushes the Docker image
2. Builds and registers the task definition with ECS
3. Deploys by either creating or updating the ECS service

Ecs-deploy does step 2 and 3 but not step 1. For step 3, doesn’t look like ecs-deploy creates a service if it doesn’t exist. It’s more designed to update existing an ECS service.

The main difference is that ecs-deploy downloads current ECS task definition and replaces the image attribute. ufo regenerates the task definition from code each deploy. If you’re making adjustments to the task definition with the ECS console as your flow, the ecs-deploy makes more sense. If you want to keep your task definition codified than ufo makes more sense.

Some more differences:

* ufo creates the CloudWatch log group if doesn’t exist. Small thing but it’s easy to forget.
* ufo has a concept of variables that get layered. This is how it handles multi environments with very similar task definitions with just a few differences.

Generally, ufo does more in scope so we’re sort of comparing apples to oranges here.  Hope that helps.

---

**Q: Is it somehow possible to change the templates for the files, that the ufo init-command generates? Most of my services follow the same overall structure, which means I'll have to perform the same changes every time I initialize a new UFO setup.**

Yes, this is achieved with the `--template` and `--template-mode` options when calling the `ufo init` command. The documentation for it is in the [ufo init reference docs](http://ufoships.com/reference/ufo-init/).

---

**Q: How can I use syslog instead of awslogs for logging?**

Open up `.ufo/templates/main.json.erb` - this gets created as part of the [ufo init](http://ufoships.com/reference/ufo-init/) command.  Then you can adjust the ecs template definition to something like this:

```json
            "logConfiguration": {
                "logDriver": "syslog"
            },
```

Here's the specific aws docs section [Specifying a Log Configuration in your Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html#specify-log-config)

Also, you might have to enable the log driver by adding the ECS_AVAILABLE_LOGGING_DRIVERS variable to your `/etc/ecs/ecs.config`. Relevant docs:

* [Using AWS Logs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html#enable_awslogs)
* [ECS Agent Install](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-install.html)

Hope that helps.

<a id="prev" class="btn btn-basic" href="{% link _docs/next-steps.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link articles.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
