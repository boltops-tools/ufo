---
title: Params
---

Additionally, the params that ufo sends to the [ruby aws-sdk](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ECS/Client.html#run_task-instance_method) methods to create resources can be customized with a `params.yml` file.  This allows you to customize the tool using the full power of the aws-sdk.

A starter project `.ufo/params.yml` file is generated as part of the `ufo init` command. Let's take a look at an example `params.yml`:

```yaml
# These params are passsed to the corresponding aws-sdk ecs client methods.
# AWS Docs example: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ECS/Client.html#run_task-instance_method
#
# The network helper provides access to the .ufo/settings/network/[PROFILE].yml
#
# More docs: http://ufoships.com/docs/params/

# ufo task calls run_tasks
run_task:
  # network_configuration is required for FARGATE
  network_configuration:
    awsvpc_configuration:
      subnets: <%= network[:ecs_subnets].inspect %> # required
      security_groups: <%= network[:ecs_security_groups].inspect %>
      assign_public_ip: "ENABLED" # accepts ENABLED, DISABLED
```

Ufo provides 1st class citizen access to adjust the params sent to the aws-sdk calls:

The parameters from this `params.yml` file get merged with params ufo generates internally.  Here's an example of where the merging happens in the source code for the run task command [task.rb](https://github.com/tongueroo/ufo/blob/master/lib/ufo/task.rb).  Also, here's the starter [params.yml source code](https://github.com/tongueroo/ufo/blob/master/lib/template/.ufo/params.yml.tt) for reference.

ERB and [shared variables]({% link _docs/variables.md %}) are available in the params file.  You can also define the subnets in your config/variables and use them in them in the params.yml file.

NOTE: The params.yml file does not have access to the `task_definition_name` helper method. That is only available in the `task_definitions.rb` template_definition code blocks.

<a id="prev" class="btn btn-basic" href="{% link _docs/settings-cfn.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/variables.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

