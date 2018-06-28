

The CloudFormation stack update or creation can possibly get stucked in an `*_IN_PROGRESS` state forever.  This happens when you deploy an ECS service that fails to stablize. This is because of an error with the docker container and it is failing to start up successfully.

There can be many reasons for this, here are some examples:

* There are no container instances available to place the docker ECS task.
* Bug in the startup script in the Dockerfile.
* You have a rails app and it is failing to connect to database upon starting up.

To resolve this you, must resolve the underlying issue.

## Canceling Deployment

You can cancel the deployment so you can fix the container issue and try again.  To do this:

    ufo cancel

You can also cancel the stack update on the CloudFormation console. The `ufo cancel` command does the same thing.
