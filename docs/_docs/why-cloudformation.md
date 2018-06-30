---
title: Why CloudFormation
---

Version 3 of ufo was a simpler implementation and did not make use of CloudFormation to create the ECS service. In version 4, ufo uses CloudFormation to create the ECS Service.  This is because ufo became more powerful. Notably, support for Load Balancers was added. With this power, also came added complexity. So some of the complexity was push onto CloudFormation.  Henece, ECS service is implemented as CloudFormation resource in version 4.

My gut was already telling me that that with Load Balancer support, the "orchestration" or sequencing logic in ufo would become annoyingly complex and shifting it to CloudFormation would be worth it. Nevertheless, I took the time with quick experimental branch and added Load Balancer using the aws-sdk directly without CloudFormation.

The pull request for that code is here [ufo/pull/42](https://github.com/tongueroo/ufo/pull/42). An additional tool was created for the non-CloudFormation approach called [balancer](https://github.com/tongueroo/balancer). Balancer can be used as a standalone tool to create load balancers in a consistent manner with "profile" files.

* [ufo/pull/42](https://github.com/tongueroo/ufo/pull/42) - PR for non-CloudFormation
* [ufo/pull/43](https://github.com/tongueroo/ufo/pull/43) - PR for CloudFormation

The results of the exercise confirm my gut.  Though the CloudFormation implementation requires more upfront investment, it ultimately pays off.  For example, route53 dns support was added to ufo extremely quickly.  Sometimes the learning curve of CloudFormation can be a deterent so I hope that these thoughts help.
