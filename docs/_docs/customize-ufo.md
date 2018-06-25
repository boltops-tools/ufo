---
title: Customize Ufo
---

Ufo uses CloudFormation for some of the resources it creates, noteably the related ELB resources and ECS service.  You might need to customize the resources that ufo creates.  There are several ways to customize the resources that ufo creates.  Here they are generally:

1. Settings - This is mainly done with the `.ufo/settings/network/default.yml` file. This is the recommended way to customize.
2. Override cfn template - You can create your own template in `.ufo/settings/cfn/default/stack.yml` as the source code to use. Use this as a hammer when only absolutely necessary.

## Settings



## Override Cfn Template


<a id="prev" class="btn btn-basic" href="{% link _docs/single-task.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/automated-cleanup.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
