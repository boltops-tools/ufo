---
title: ufo scale
---

Ufo provides a command to quickly scale up and down an ECS service. Here's an example of how you use it:

```sh
ufo scale hi-web
```

You should get output similiar to below:

```sh
Scale hi-web service in stag cluster to 3
```

While scaling via this method is quick and convenient the [ECS Service AutoScaling](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html) that is built into ECS is a much more powerful way to manage scaling your ECS service.

<a id="prev" class="btn btn-basic" href="{% link _docs/ufo-ships.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-destroy.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>


