---
title: Docs
---

### Overview

Ufo is a tool that makes building and shipping Docker containers to AWS ECS super easy. Ufo provides a `ufo ship` command that does this. Essentially:

1. ufo builds the docker container image
2. registers that image to ECS as a task definition
3. deploys that registered task definition to ECS by updating the service.

Ufo was built directly from real life production use cases after seeing the same patterns repeated over and over. Ufo enables you to write the AWS task definition json format file in ERB, an easy templating language.  This allows you to reuse the ufo tool with multiple applications and only put the truly application specific business logic in each app code base.

Next we'll cover different ways to install ufo.

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-ufo-ships.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/structure.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

