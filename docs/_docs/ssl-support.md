---
title: SSL Support
---

You can configure SSL support by uncomment the `listener_ssl` option in `.ufo/settings/cfn/default.yml`.  Here's an example:

```
listener_ssl:
  port: 443
  certificates:
  - certificate_arn: arn:aws:acm:us-east-1:111111111111:certificate/11111111-2222-3333-4444-555555555555
```

For the certificate arn, you will need to create a certificate with AWS ACM. To do so, you can follow these instructions: [Request a Public Certificate
](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html)

The protocol will be either HTTP or HTTPS for Application Load Balancers and TCP or TLS for Network Load Balancers. Ufo will infer the right value, so you usually don't have to configure the protocol manually.  You can configure it if required though.

<a id="prev" class="btn btn-basic" href="{% link _docs/ecs-network-mode.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/route53-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
