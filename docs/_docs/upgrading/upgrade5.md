---
title: Upgrading to Version 5
short_title: Version 5
order: 1
categories: upgrading
nav_order: 39
---

In ufo v5, the ufo went from underscore key names in the [cfn settings files]({% link _docs/settings/cfn.md %}) to camelized key names. So the auto_camelize behavior is disabled for newly `ufo init` projects. This mean ufo is backwards compatiable. You can enable the v5 behavior with `auto_camelize: false`. If you have not adjusted this setting, then ufo should still work with your current `.ufo` files.

## Upgrading Instructions

If you want to upgrade to the latest ufo v5 default behavior.

1. Adjust your .ufo/settings/cfn files so that the keys are camelized
2. Add to your .ufo/settings.yml `auto_camelize: false`
3. Deploy and verify that your ECS app stil works

{% include prev_next.md %}
