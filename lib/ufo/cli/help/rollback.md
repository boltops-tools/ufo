## Examples

You only need to specific the task definition version number, though you can specify the name also

    $ ufo rollback 54
    Will rollback to task definition version: 54
    Are you sure? (y/N) y
    Rolling back ECS service to task definition demo-web-dev:54
    Will deploy stack demo-web-dev
    Parameters built:      .ufo/output/params.json
    Template built:        .ufo/output/template.yml
    Updating stack demo-web-dev
    Waiting for stack to complete
    06:17:01PM UPDATE_IN_PROGRESS AWS::CloudFormation::Stack demo-web-dev User Initiated
    06:17:08PM UPDATE_IN_PROGRESS AWS::ECS::Service EcsService
    ..

To see recent task definitions:

    ufo releases

Note, task definitions get created by many ways with more than just `ufo ship`. So it the previous version might not be the latest version number minus one.

## Using image name

Another way to specify the version for rollback is with the container definition's image value.  Here's the portion of the ecs task definition that you would look for:

    ...
    "container_definitions": [
      {
        "name": "web",
        "image": "org/repo:ufo-2018-06-21T15-03-52-ac60240",
        "cpu": 256,
    ...

You need to specify enough for a match to be found.  Ufo searches the 30 most recent task definitions. So all of these would work:

    ufo rollback org/repo:ufo-2018-06-21T15-03-52-ac60240
    ufo rollback 2018-06-21T15-03-52
    ufo rollback ac60240
