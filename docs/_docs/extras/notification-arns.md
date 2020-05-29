---
title: Notification ARNs
categories: extras
nav_order: 99
---

You can specific notification arns for CloudFormation stack related events with [configs/settings.yml]({% link _docs/settings.md %}). This may be useful for compliance purposes.

## Example

configs/settings.yml

```yaml
base:
  notification_arns:
  - arn:aws:sns:us-west-2:112233445566:my-sns-topic1
```

This will set the `notification_arns` option as the CloudFormation stack created by `ufo ship`.

{% include prev_next.md %}
