---
title: Upgrading to Version 4.0
short_title: Version 4.0
order: 2
categories: upgrading
nav_order: 34
---

A major change in ufo from version 3 to 4 is that the ECS service is now created by CloudFormation. If you have an existing ECS service deployed by ufo version 3, when you deploy your app again with ufo version 4, there will be a new additional ECS service created. Here is the recommended upgrade path.

## Upgrade Steps Summary

The upgrade path recommended here should result in zero downtime. It is effectively a blue/green deployment with a DNS switchover.

1. Run `ufo upgrade v3to4` in your project folder.
2. Check the changed files.
3. Run `ufo ship SERVICE`.
4. Confirm your new service is working. `ufo ps` and `ufo apps` is useful.
5. Switch the DNS to the new service's endpoint.
6. Confirm everything on the new service works.
7. Destroy the old ECS service with the ECS console. Do not destroy it with `ufo destroy` as the `ufo destroy` command will destroy the newly created service.

Note, with ufo version 4, load balancers are supported and automatically created for web services. If you want to use the existing load balancer, you can do so by specifying `--elb existing-target-group-arn`.

### ufo upgrade v3to4

It is recommended that you run the `ufo upgrade v3to4` command with the network options specified. Please substitute the command with the vpc id and subnets for your setup.  Example:

    $ ufo upgrade v3to4 --vpc-id vpc-111 --ecs-subnets subnet-111 subnet-222 --elb-subnets subnet-333 subnet-444 --force
    Upgrading structure of your current project to the new ufo version 4 project structure
          append  .dockerignore
          append  .gitignore
           force  .ufo/params.yml
          create  .ufo/settings/cfn/default.yml
          create  .ufo/settings/network/default.yml
    Upgrade complete.

If you run the upgrade command without specified options, then ufo will detect and use the default vpc and subnets, which might not be what you want.  Inspect the files and verify that they are what you desired.

### Verify changed files

File | Changes
--- | ---
.ufo/params.yml | The create_service and update_service sections have been removed. The options handed by CloudFormation and can be customized with `.ufo/settings/cfn/default.yml`. If you have used these options for Fargate support, you no longer need to worry about them.  The generated CloudFormation template detects if the task definition uses Fargate and handles it for you.
.ufo/settings/cfn/default.yml | Starter cfn settings file.
.ufo/settings/network/default.yml | This generated file will have the vpc and subnets that you specified above.  You can change them directly in this file to control what network settings ufo uses.

{% include prev_next.md %}