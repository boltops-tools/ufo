{:.ship-options}
Option  | Description
------------- | -------------
`--cluster`  | This decides what cluster to use.  This can also be set in ufo/settings.yml covered in [Settings]({% link _docs/settings.md %}).  The cli option takes highest precedence.
`--ecr-keep`  | This integer option determines how many old docker images to keep around.  Ufo will automatically delete and clean up docker images at the end of this process. The default is to keep all.  If you set this, set it at a reasonable high number like 30.
`--elb-eip-ids` | EIP Allocation ids to use for network load balancer.  If specified then `--elb-type` is automatically assumed to be `network`.
`--elb-type` |  ELB type: application or network. Keep current deployed elb type when not specified.
`--elb` | Decides to create elb, not create elb or use existing target group.
`--pretty`  | This boolean option determines ufo generates the task definitions in output in a pretty human readable format.
`--stop-old-tasks`  | This boolean option determines if ufo will call ecs stop-task on the old tasks after deployment. Sometimes old tasks hang around for a little bit with ECS this forces them along a little quicker. This option forceably kills running tasks, so configuring `deregistration_delay.timeout_seconds` is recommended in the cfn settings instead. Note, it seems like deregistration_delay is currently is respected for Application ELBs but not Network ELBs.
`--task`  | By convention ufo uses the same name for both the ECS service and task definition. You can override this convention with this option.  The conventions are covered on the [Conventions]({% link _docs/conventions.md %}) page.
`--wait`  | This boolean option determines if ufo blocks and waits until the service has been deployed before continuing.
