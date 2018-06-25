---
title: Uprading to Version 4
---

A major change in ufo from version 3 to 4 is that the ECS service is now created and managed by CloudFormation. So when you deploy your service with ufo version 4 for the first time it will create a new ecs additional ECS service.

## Recommended upgrade steps

The upgrade path recommend here should result in zero downtime. It is effectively a blue green deployment with a dns switchover.

1. run `ufo upgrade v3to4`
2. check the changed files
3. run `ufo ship SERVICE`
4. confirm your new service is working. `ufo ps` and `ufo apps` might be useful.
5. switch the dns to the new service's endpoint.
6. confirm everything is still working.
7. destroy the old ecs service with the ECS console. Do not destroy it with `ufo destroy` as the `ufo destroy` command will destroy the newly created service.

Note, with ufo version 4, load balancers are supported and automatically created for web containers. So it is should be straightforward to upgrade as you do not have to re-create the load balancer.

<a id="prev" class="btn btn-basic" href="{% link _docs/params.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/variables.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
