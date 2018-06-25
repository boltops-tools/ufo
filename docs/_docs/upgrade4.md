---
title: Uprading to Version 4
---

A major change in ufo from version 3 to 4 is that the ECS service is now created and managed by CloudFormation. So when you deploy your service with ufo version 4 for the first time it will create a new ecs additional ECS service.

## Upgrade Steps Summary

The upgrade path recommend here should result in zero downtime. It is effectively a blue green deployment with a dns switchover.

1. run `ufo upgrade v3to4`
2. check the changed files
3. run `ufo ship SERVICE`
4. confirm your new service is working. `ufo ps` and `ufo apps` might be useful.
5. switch the dns to the new service's endpoint.
6. confirm everything is still working.
7. destroy the old ecs service with the ECS console. Do not destroy it with `ufo destroy` as the `ufo destroy` command will destroy the newly created service.

Note, with ufo version 4, load balancers are supported and automatically created for web containers. So it is should be straightforward to upgrade as you do not have to re-create the load balancer.

### ufo upgrade v3to4

It is recommend that you run the `ufo upgrade v3to4` command with the network options specified. Example:

    $ ufo upgrade v3to4 --vpc-id vpc-111 --ecs-subnets subnet-111 subnet-222 --elb-subnets subnet-333 subnet-444
    Upgrading structure of your current project to the new ufo version 4 project structure
          append  .dockerignore
          append  .gitignore
        conflict  .ufo/params.yml
    Overwrite /Users/tung/src/clients/laurelroad/lr-infrastructure/deployers/blaze/.ufo/params.yml? (enter "h" for help) [Ynaqdh] a
           force  .ufo/params.yml
        conflict  .ufo/settings.yml
           force  .ufo/settings.yml
          create  .ufo/settings/network/default.yml
    Upgrade complete.

Please substitute the command with the vpc id and subnets for your setup.  If you run the upgrade command without specified options, then ufo will detect and use the default vpc and subnets, which might not be what you want.  After the comand verify that the generated files match with what you expected.

### Verify changed files

File | Changes
--- | ---
.ufo/params.yml | The create_service and update_service sections have been removed. The options are no longer supported and are handed by CloudFormation. If you have used these options for Fargate support, you no longer need to worry about them as the generated CloudFormation template will handle Fargate support for you without the need to customize.  It does this by checking your task definition.
.ufo/settings.yml | A network_profile option has been added.
.ufo/settings/network/default.yml | This generated file will have the vpc and subnets that you specified above.  You can change them directly in this file to control what network settings ufo uses.  You'll alos notice that


<a id="prev" class="btn btn-basic" href="{% link _docs/params.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/variables.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
