---
title: ELB Support
---

## CLI

    ufo balancer init --subnets subnet-aaa subnet-bbb --vpc-id vpc-123
    ufo init --subnets subnet-aaa subnet-bbb --vpc-id vpc-123

## Settings

```
development:
  balancer_profile: default

production:
  balancer_profile: production
```

<a id="prev" class="btn btn-basic" href="{% link _docs/settings.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-env.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
