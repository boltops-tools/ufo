---
title: Security Groups
---

Ufo creates and manages two security groups. One for the ELB and one for the ECS tasks.

Some consideration for these security groups:

* Network load balancers do not support security groups. So an ELB security group is only created if the load balancer is an Application load balancer.
* The ECS security group for tasks currently always gets created, but is only used if network_mode is awsvpc. This is because in bridge network mode the EC2 container instance’s Ethernet card and its security group is used. The EC2 containers group security group is outside the control of ufo. You’ll need to configure the security group appropriately yourself. Ufo will only assign the ECS security group when awsvpc node mode is used and ufo has control of the security group.

## EC2 Instance Security Group Help

If you are seeing that the Targets in the ELB Target Group are reporting unhealthy, it is usually a security group issue.  You might see this out with `ufo ps`:

    $ ufo ps --no-summary
    +----------+------+--------------+----------------+---------+-------------------------+
    |    Id    | Name |   Release    |    Started     | Status  |          Notes          |
    +----------+------+--------------+----------------+---------+-------------------------+
    | 070a9c0a | web  | demo-web:169 | 6 minutes ago  | STOPPED | Failed ELB health check |
    | d02728ba | web  | demo-web:169 | 3 minutes ago  | STOPPED | Failed ELB health check |
    | 8dcf81ae | web  | demo-web:169 | 13 seconds ago | RUNNING |                         |
    +----------+------+--------------+----------------+---------+-------------------------+
    There are targets the target group reporting unhealthy.  This can cause containers to cycle. Here's the error:
    (service development-demo-web-Ecs-13D2BFA4ULNC9) (instance i-0812a3bcd94babf12) (port 32779) is unhealthy in (target-group arn:aws:elasticloadbalancing:us-east-1:111111111111:targetgroup/devel-Targe-1MJR8V6VOWBGI/3f44f85710fe0297) due to (reason Request timed out)
    Check out the ECS console events tab for more info.
    $

If you are using network mode bridge, then you'll need to need to configure the container instance's security group to allow traffic to the Docker ephemeral port range. For details on the Docker ephemeral port range on AWS, you search for "ephemeral" on the [ECS Port Mapping Docs](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_PortMapping.html).

In general, ports below 32768 are outside of the ephemeral port range. So an easy way to configure the container instance's security group is to whitelist ports 32768 to 65535 to your VPC's CIDR block. An example of a CIDR block range could be `10.0.0.0/16`. The CIDR block is being suggested because the Application load balancer and security group created by ufo can change if you change the load balancer settings.

If you are using a network load balancer and are running bridge network mode, then you need to whitelist ports 32768 to 65535 to `0.0.0.0/0`.  This is because network load balancers operate at layer 4 of the OSI model and cannot be assigned security groups, so they use the security group of the instance.  If you feel this is too loose of permissions, you can use awsvpc mode. There are some considerations for awsvpc mode though which is discussed next.

## Pros and Cons: awsvpc vs bridge network mode

With network bridge mode, the Docker containers of multiple services share the EC2 container instance's security group. So you have less granular control over opening ports for specific services only. For example, let’s say service A and B both are configured use bridge network mode. If you open up port 3000 for service A, it will also open up port 3000 for service B because they use the same security group at the EC2 instance level.

One advantage of bridge mode is you can use dynamic port mapping and do not have to worry about network card limits.

With awsvpc network mode, you must consider the limit of ethernet cards for the instance type. The table that lists the limits are under section the aws EC2 docs under [IP Addresses Per Network Interface Per Instance Type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html) For example, a t2 large instance has a limit of 3 Ethernet cards. This means, at most, you can run 3 ECS tasks on that instance in awsvpc network mode.

The advantage of awsvpc mode is that since the ECS task has its own network card and security group, there’s more granular control of the permissions per ECS service. For example, when service A and B are using awsvpc mode, they can have different security groups associated with them. In this mode, ufo creates a security group and sets up the permissions so the load balancer can talk to the containers.  You can also add additional security group to the `.ufo/settings/network/default.yml` config.

The following table summarizes the pros and cons:

Network mode | Pros | Cons
--- | ---
bridge | The numbers of containers you can run will not be limited due to EC2 instance network cards limits. | Less fine grain security control over security group permissions with multiple ECS services.
awsvpc | Fine grain security group permissions for each ECS service. | The number of containers can be limited by the number of network cards the EC2 instance type supports.

<a id="prev" class="btn btn-basic" href="{% link _docs/load-balancer.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ssl-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
