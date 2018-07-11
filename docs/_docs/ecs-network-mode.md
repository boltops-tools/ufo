---
title: ECS Network Mode
---

## Pros and Cons: awsvpc vs bridge network mode

With network bridge mode, the Docker containers of multiple services share the EC2 container instance's security group. So you have less granular control over opening ports for specific services only. For example, let’s say service A and B both are configured use bridge network mode. If you open up port 3000 for service A, it will also open up port 3000 for service B because they use the same security group at the EC2 instance level.

One advantage of bridge mode is you can use dynamic port mapping and do not have to worry about network card limits.

With awsvpc network mode, you must consider the limit of ethernet cards for the instance type. The table that lists the limits are under section the aws EC2 docs under [IP Addresses Per Network Interface Per Instance Type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html) For example, a t2.large instance has a limit of 3 ethernet cards. This means, at most, you can run 3 ECS tasks on that instance in awsvpc network mode.  The network card limit ranges from 3 to 15 ethernet cards depending on the instance type.

The advantage of awsvpc mode is that since the ECS task has its own network card and security group, there’s more granular control of the permissions per ECS service. For example, when service A and B are using awsvpc mode, they can have different security groups associated with them. In this mode, ufo creates a security group and sets up the permissions so the load balancer can talk to the containers.  You can also add additional security group to the `.ufo/settings/network/default.yml` config.

The following table summarizes the pros and cons:

Network mode | Pros | Cons
--- | ---
bridge | The numbers of containers you can run will not be limited due to EC2 instance network cards limits. | Less fine grain security control over security group permissions with multiple ECS services.
awsvpc | Fine grain security group permissions for each ECS service. | The number of containers can be limited by the number of network cards the EC2 instance type supports.

<a id="prev" class="btn btn-basic" href="{% link _docs/security-groups.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ssl-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
