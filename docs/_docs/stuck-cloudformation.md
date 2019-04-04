---
title: Stuck CloudFormation
nav_order: 31
---

The CloudFormation stack update or creation can get stuck in a `*_IN_PROGRESS` state for a very long time, like more than an hour.  This happens when you deploy an ECS service that fails to stabilize. Usually, this is an error with the Docker container failing to start up successfully.
There can be many reasons for this, here are some examples:

* Bug in the startup script in the Dockerfile.
* There are no container instances available to place the docker ECS task.
* You have a rails app and it is failing to connect to the database upon startup, maybe due to a security group setting.

To resolve this, you can:

1. cancel the current deploy
2. fix the underlying issue
3. deploy again

## Canceling Deployment

If an ECS deployment does not finish within 10 minutes because the ECS service is not stabilizing, it is usually due one of the reasons above. In these cases, it is safe to cancel and try again.

To cancel a current deploy, run:

    ufo cancel

This is the same thing as canceling the stack update in the CloudFormation console.

{% include prev_next.md %}