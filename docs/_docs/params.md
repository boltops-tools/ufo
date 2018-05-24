---
title: Params
---

Additionally, the params that ufo sends to the [ruby aws-sdk](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ECS/Client.html#run_task-instance_method) methods to create resources can be customized with a `params.yml` file.  This allows you to customize the tool using the full power of the aws-sdk.

A starter project `.ufo/params.yml` file is generated as part of the `ufo init` command. Let's take a look at an example `params.yml`:

```yaml
<%
  # replace with actual values:
  @subnets = ["subnet-111","subnet-222"]
  @security_groups = ["sg-111"]
%>
# These params are passsed to the corresponding aws-sdk ecs client methods.
# AWS Docs example: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ECS/Client.html#run_task-instance_method
#
# Comments left in as examples.
# Uncomment launch_type and network_configuration sections to enable fargate.
#

# ufo ship calls create_service when service doesnt exist
create_service:
  deployment_configuration:
    maximum_percent: 200
    minimum_healthy_percent: 100
  desired_count: 1
  # launch_type: "FARGATE"
  # network_configuration:
  #   awsvpc_configuration:
  #     subnets: <%= @subnets.inspect %> # required
  #     security_groups: <%= @security_groups.inspect %>
  #     assign_public_ip: "ENABLED" # accepts ENABLED, DISABLED


# ufo ship calls update_service when service already exists
# update service is provide as an example below.  Though it is probably better
# to not add any options to update_service if you are using the ECS console
# to update these settings often.
update_service:

# ufo task calls run_tasks
run_task:
  # launch_type: "FARGATE"
  # network_configuration:
  #   awsvpc_configuration:
  #     subnets: <%= @subnets.inspect %> # required
  #     security_groups: <%= @security_groups.inspect %>
  #     assign_public_ip: "ENABLED" # accepts ENABLED, DISABLED
```

Ufo provides 1st class citizen access to adjust the params sent to the aws-sdk calls:

* create_service - `ufo ship` calls this when the ECS service does not yet exist.
* update_service - `ufo ship` calls this when the ECS service already exists.
* run_task - `ufo task` calls this.

The parameters from this `params.yml` file get merged with params ufo generates internally.  Here's an example of where the merging happens in the source code for the run task command [task.rb](https://github.com/tongueroo/ufo/blob/90f12df035843528770122deb328d150249a25e2/lib/ufo/task.rb#L20).  Also, here's the starter [params.yml source code](https://github.com/tongueroo/ufo/blob/master/lib/template/.ufo/params.yml) for reference.

ERB and variables are available in the params file.  Notice how ERB is used at the top of the example file to set some subnets to prevent duplication.

<a id="prev" class="btn btn-basic" href="{% link _docs/settings.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-env.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

