---
title: ECS Network Mode
nav_order: 27
---

## Pros and Cons: bridge network mode

With network bridge mode, the Docker containers of multiple services share the EC2 container instance's security group. So you have less granular control over opening ports for specific services only. For example, let’s say service A and B both are configured use bridge network mode. If you open up port 3000 for service A, it will also open up port 3000 for service B because they use the same security group at the EC2 instance level.

One advantage of bridge mode is you can use dynamic port mapping and do not have to worry about network card limits.

## Pros and Cons: awsvpc mode

With awsvpc network mode, you must consider the limit of ethernet cards for the instance type. If the instance supports ENI Trunking, then this is limit is decently large. However, if the instance does not support ENI Trunking, then the ENI limit is rather small.

For ENI Trunking Task limits per instance: [Elastic Network Interface Trunking](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-eni.html)

For example, a m5.large instance has a limit of 10 tasks per instance.
For EC2 instances that do not support ENI Trunking,
the table that lists the limits are under section the aws EC2 docs under [IP Addresses Per Network Interface Per Instance Type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html)

For example, a t3.small instance has a limit of 3 ethernet cards. This means, at most, you can run 2 ECS tasks on that instance in awsvpc network mode, since one network card is already used by the host.

In awsvpc mode, each ECS task gets its own network card. The advantage is there’s more granular control of the permissions per ECS service. For example, when service A and B are using awsvpc mode, they can have different security groups associated with them. In this mode, ufo creates a security group and sets up the permissions so the load balancer can talk to the containers.  You can also add additional security groups to the `.ufo/settings/network/default.yml` config.

The following table summarizes the pros and cons:

Network mode | Pros | Cons
--- | ---
bridge | The numbers of containers you can run will not be limited due to EC2 instance network cards limits. | Less fine grain security control over security group permissions with multiple ECS services.
awsvpc | Fine grain security group permissions for each ECS service. | The number of containers can be limited by the number of network cards the EC2 instance type supports.

## Recommendation

It is generally recommended to use awsvpc mode with ENI trunking supported instances. You get the best of both worlds in this situation: a strong security posture as well as container density.

{% include prev_next.md %}
