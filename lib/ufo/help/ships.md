Builds docker image, registers it and ships it to multiple services.  This deploys the same docker image to multiple ECS services.

Examples:

  ufo ships hi-web-prod hi-clock-prod hi-worker-prod

By convention the task definition and service names match for each of the services you ship. If you need to override to this convention then you can specify the task definition for each service with a special syntax.  In the special syntax the service and task definition is separated by a colon.  Example:

  ufo ships hi-web-prod-1:hi-web-prod hi-clock-prod-1 hi-worker-prod-1

Here ufo will deploy to the hi-web-prod-1 ECS Service using the hi-web-prod task definition, but use the convention for the rest of the service.

For each service being deployed to, ufo will create the ECS service if the service does not yet exist on the cluster.  The deploy process will prompt you for the ELB `--target-group` if you are deploying to a 'web' service that does not yet exist.  Ufo determines that it is a web service by the name of the service. If the service has 'web' in the name then it is considered a web service. If it is not a web service then the `--target-group` option gets ignored.

The prommpt can be bypassed by specifying a valid `--target-group` option or specifying the `---no-target-group-prompt` option.  Examples:

  ufo ships hi-web-prod hi-clock-prod hi-worker-prod --target-group arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/hi-web-prod/jsdlfjsdkd
  ufo ships hi-web-prod hi-clock-prod hi-worker-prod --no-target-group-prompt
