---
title: FAQ
---

**Q: Is AWS ECS Fargate supported?**

Yes, Fargate is supported.  To use ufo with Fargate, the you should adjust the the template in `.ufo/templates` to use the Fargate structure.  If it's a brand new project. You can use `ufo init` with the `--launch-type fargate` option and it will generate a json file that has the right Fargate structure. Notable, it requires requiresCompatibilities, networkMode and executionRoleArn to be set.

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

**Q: How can I used syslog instead of awslogs for logging?**

Open up `.ufo/templates/main.json.erb` - this gets created as part of the [ufo init](http://ufoships.com/reference/ufo-init/) command.  Then you can adjust the ecs template definition to something like this:

```json
            "logConfiguration": {
                "logDriver": "syslog"
            },
```

Here's the specific aws docs section [Specifying a Log Configuration in your Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html#specify-log-config)

Also, you might have to enable the log driver by added it the ECS_AVAILABLE_LOGGING_DRIVERS variable to your `/etc/ecs/ecs.config`. Relevant docs:

* [Using AWS Logs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html#enable_awslogs)
* [ECS Agent Install](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-install.html)

Hope that helps.

<a id="prev" class="btn btn-basic" href="{% link _docs/next-steps.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link articles.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
