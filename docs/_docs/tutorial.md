---
title: Tutorial
nav_order: 4
---

In the next sections, we'll walk through using ufo in detail. We will ufo-ify a project. Then we'll go through the step by step process that ufo automated.  Normally ufo is not really used in step like fashion like in this tutorial, but going through it step by step really helps to understand how ufo works.  Here are the steps we'll go through:

1. We'll build a docker image by using `ufo docker`.
2. We'll build and register the task definitions to ECS with the newly built docker images with `ufo tasks`
3. Finally, we'll use `ufo ship` to run through entire process.

Let's start!

{% include prev_next.md %}
