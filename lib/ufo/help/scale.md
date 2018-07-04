Ufo provides a command to scale up and down an ECS service quickly. It is a simple wrapper for `aws ecs update-service --service xxx ----desired-count xxx`.  Here's an example of how you use it:

    $ ufo scale 3
    Scale demo-web service in development cluster to 3

It is useful to use `ufo ps` to check the status.

    $ ufo ps
    => Service: demo-web
       Service name: development-demo-web-Ecs-7GAUAXH5F56M
       Status: ACTIVE
       Running count: 2
       Desired count: 3
       Launch type: FARGATE
       Task definition: demo-web:85
       Elb: develop-Elb-1M74CLRS2G0Z4-686742146.us-east-1.elb.amazonaws.com
    +----------+------+-------------+----------------+--------------+-------+
    |    Id    | Name |   Release   |    Started     |    Status    | Notes |
    +----------+------+-------------+----------------+--------------+-------+
    | 8f95ef9d | web  | demo-web:85 | PENDING        | PROVISIONING |       |
    | f590ee5e | web  | demo-web:85 | 50 minutes ago | RUNNING      |       |
    | fb60ba9f | web  | demo-web:85 | 48 minutes ago | RUNNING      |       |
    +----------+------+-------------+----------------+--------------+-------+
    $

While scaling via this method is quick and convenient the [ECS Service AutoScaling](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html) that is built into ECS is a much more powerful way to manage scaling your ECS service.
