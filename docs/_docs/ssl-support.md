---
title: SSL Support
---

## Application Load Balancers

If you are using an Application Load Balancer you can configure SSL support by adjusting the `listener_ssl` in `.ufo/settings/cfn/default.yml`.  Here's an example:

```
listener_ssl:
  port: 443
  certificates:
  - certificate_arn: arn:aws:acm:us-east-1:111111111111:certificate/11111111-2222-3333-4444-555555555555
```

For the certificate arn, you will need to create a certificate with AWS ACM. To do so, you can follow these instructions: [Request a Public Certificate
](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html)

Once this is configured, you deploy the app again:

    ufo ship

## Network Load Balancers

Network Load Balancers work at layer 4, so they do not support SSL termination because SSL happens higher up in the OSI model layers. With Network Load Balancers you handle SSL termination within your app with the server you are using.  For example, it could be apache, nginx or tomcat.

You also will need to also configure the target group to check the port that your app server is listening to and configure the health_check_protocol to HTTPS.  Here's an example:

```
listener_ssl:
  port: 443
target_group:
  port: 443
  health_check_protocol: HTTPS
```

The protocol in the case of the network load balancer is TCP and is configured to TCP by default by ufo for Network Load Balancers, so you don't have to configure it.

<a id="prev" class="btn btn-basic" href="{% link _docs/security-groups.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/route53-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
