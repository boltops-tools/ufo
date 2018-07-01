---
title: SSL Support
---

## Application Load Balancers

If you are using an Application Load Balancer you can configure SSL support by adjusting the listener in `.ufo/settings/cfn/default.yml`.  Here's an example:

```
listener:
  port: 443
  protocol: HTTPS
  certificates:
  - certificate: arn:aws:acm:us-east-1:111111111111:certificate/11111111-2222-3333-4444-555555555555
```

For the certificate arn, you will need to create a certificate with AWS ACM. To do so, you can follow these instructions: [Request a Public Certificate
](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html)

Once this is configured, you deploy the app again:

    ufo ship

## Network Load Balancers

Network Load Balancers work at layer 4, so they do not support SSL termination because SSL happens higher up in the OSI model layers. With Network Load Balancers you handle SSL termination within your app with the app server you are using.  For example, it could be apache, nginx or tomcat.

You also will need to configure the target group to check the port that your app server is listening to and configure the health_check_protocol to HTTPS.  Here's an example:

```
target_group:
  port: 443
  health_check_protocol: HTTPS
```

<a id="prev" class="btn btn-basic" href="{% link _docs/load-balancer.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/route53-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
