---
title: Upgrading
nav_order: 38
---

<ul>
{% assign docs = site.docs | where: "categories","upgrading" | sort: "order" %}
{% for doc in docs -%}
  <li><a href='{{doc.url}}'>{{doc.title}}</a></li>
{% endfor %}
</ul>

{% include prev_next.md %}
