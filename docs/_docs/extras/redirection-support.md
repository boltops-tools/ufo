---
title: Redirection Support
nav_order: 30
---

## Application Load Balancers

If you are using an Application Load Balancer you can configure redirection by editing the default actions of the regular listener that is set up by ufo. This assumes you have set up [SSL Support]({% link _docs/extras/ssl-support.md %}).  Here's an example that redirects http to https with a 302 http status code:

```
listener:
  port: 80
  # ...
  default_actions:
   - type: redirect
     redirect_config:
       protocol: HTTPS
       status_code: HTTP_302 # HTTP_301 and HTTP_302 are valid
       port: 443
```


## Network Load Balancers

Network Load Balancers work at layer 4, so they do not support redirection.  Instead you need to handle redirection within your app.

{% include prev_next.md %}
