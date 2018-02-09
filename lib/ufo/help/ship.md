Examples:

To build the docker image, generate the task definition and ship it, run:

  ufo ship hi-web-prod

By convention the task and service names match. If you need override to this convention then you can specific the task.  For example if you want to ship to the `hi-web-prod-1` service and use the `hi-web-prod` task, run:

  ufo ship hi-web-prod-1 --task hi-web-prod

The deploy will also created the ECS service if the service does not yet exist on the cluster.  The deploy will prompt you for the ELB `--target-group` if you are shipping a web container that does not yet exist.  If it is not a web container the `--target-group` option gets ignored.

The prommpt can be bypassed by specifying a valid `--target-group` option or specifying the `---no-target-group-prompt` option.

  ufo ship hi-web-prod --target-group arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/hi-web-prod/jsdlfjsdkd

  ufo ship hi-web-prod --no-target-group-prompt
