---
title: Auto Completion
nav_order: 37
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

{% include prev_next.md %}