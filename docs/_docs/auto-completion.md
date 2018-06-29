---
title: Auto Completion
---

Ufo supports bash auto-completion.  To set it up add the following to your `~/.profile` or `.bashrc`:

```
eval $(ufo completion_script)
```

Remember to restart your shell or source your profile file.

Auto Completion examples:

```
ufo [TAB]
ufo ship [TAB]
ufo ship demo-web [TAB]
ufo ship demo-web --[TAB]
ufo ship --[TAB]
ufo docker [TAB]
ufo docker build [TAB]
ufo tasks [TAB]
ufo tasks build [TAB]
```

<a id="prev" class="btn btn-basic" href="{% link _docs/conventions.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/run-in-pieces.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
