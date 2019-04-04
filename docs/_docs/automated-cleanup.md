---
title: Automated Clean Up
nav_order: 36
---

Ufo can be configured to automatically clean old images from the ECR registry after the deploy completes by configuring your [settings.yml]({% link _docs/settings.md %}) file like so:

```yaml
ecr_keep: 30
```

Automated Docker images clean up only works if you are using ECR registry.

{% include prev_next.md %}