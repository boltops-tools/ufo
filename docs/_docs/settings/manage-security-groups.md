---
title: Managed Security Groups
short_title: Security Groups
categories: settings
nav_order: 16
---

Ufo creates and manages two security groups. One for the ELB and one for the ECS tasks. Details here: [UFO Security Groups]({% link _docs/extras/security-groups.md %}).

You can disable the creation of managed security groups with: `managed_security_groups: false`. Example:

```yaml
base:
  image: tongueroo/demo-ufo
  managed_security_groups: false
```

## Why?

Security Groups managed by UFO are transient. If you delete the UFO app and recreate it entirely. Any manual changes to the security groups will be lost.

You can precreate security groups and add them generated UFO CloudFormation template, see [Settings Network]({% link _docs/settings/network.md %}). So then you won't lose any manual changes. If you're taking this approach, it's nice to have UFO not create any managed security groups at all. This removes security group clutter.

{% include prev_next.md %}
