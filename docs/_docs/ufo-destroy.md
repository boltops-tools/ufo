---
title: ufo destroy
---

Ufo provides a quick way to destroy an ECS service. In order to destroy an ECS service you must makes sure that the desired number of tasks is first set to 0. It is easy to forgot to do this and waste time. So as part of destroying the service ufo will scale the ECS service down to 0 automatically first and then destroy the service.  Ufo also prompts you before destroying the service.

```
ufo destroy hi-web
```

If you would like to bypass the prompt you can use the `--sure` option.

```
ufo destroy hi-web --sure
```

<a id="prev" class="btn btn-basic" href="{% link _docs/ufo-scale.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-docker-build.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
