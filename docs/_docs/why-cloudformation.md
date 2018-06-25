---
title: Why CloudFormation
---

Version 3 of ufo contained a simpler implementation and did not make use of CloudFormation to create the ECS service. In version 4, ufo became more powerful and also complex. Notable, native support for Load Balancers was added. So CloudFormation was introduced and the ECS service is implemented as CloudFormation resource in version 4.

My gut was already telling me that that with Load Balancer support, the "orchestration" or sequencing logic in ufo would become annoyingly complex and shift it to CloudFormation would be worth it. Nevertheless, I took the time to do a quick experimental branch and added Load Balancer using the aws-sdk directly without CloudFormation.

The pull request for that code is here [ufo/pull/42](https://github.com/tongueroo/ufo/pull/42). An additional tool was created for the non-CloudFormation approach called [balancer](https://github.com/tongueroo/balancer). Balancer can be used as a standalone tool to create load balancers in a consistent manner with "profile" files.

* [ufo/pull/42](https://github.com/tongueroo/ufo/pull/42) - PR for non-CloudFormation
* [ufo/pull/43](https://github.com/tongueroo/ufo/pull/43) - PR for CloudFormation

The results of the exercised confirm my gut.  Sometimes the learning curve of CloudFormation can deter and the CloudFormation implmentation required a more upfront investment.  It ultimately pays off.  For example, route53 dns support was added to ufo extremely quickly.  Hope that these thoughts help.
