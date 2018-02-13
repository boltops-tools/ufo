---
title: Automated Clean Up
---

Ufo can be configured to automatically clean old images from the ECR registry after the deploy completes by configuring the your [settings.yml]({% link _docs/settings.md %}) file like so:

```yaml
ecr_keep: 30
```

Automated Docker images clean up only works if you are using ECR registry.

<a id="prev" class="btn btn-basic" href="{% link _docs/migrations.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/next-steps.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
