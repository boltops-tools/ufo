## Examples

    $ ufo ps
    => Service: demo-web
       Service name: development-demo-web-Ecs-7GAUAXH5F56M
       Status: ACTIVE
       Running count: 2
       Desired count: 2
       Launch type: FARGATE
       Task definition: demo-web:85
       Elb: develop-Elb-1M74CLRS2G0Z4-686742146.us-east-1.elb.amazonaws.com
    +----------+------+-------------+----------------+---------+-------+
    |    Id    | Name |   Release   |    Started     | Status  | Notes |
    +----------+------+-------------+----------------+---------+-------+
    | f590ee5e | web  | demo-web:85 | 47 minutes ago | RUNNING |       |
    | fb60ba9f | web  | demo-web:85 | 45 minutes ago | RUNNING |       |
    +----------+------+-------------+----------------+---------+-------+

Skip the summary info:

    $ ufo ps --no-summary
    +----------+------+-------------+----------------+---------+-------+
    |    Id    | Name |   Release   |    Started     | Status  | Notes |
    +----------+------+-------------+----------------+---------+-------+
    | f590ee5e | web  | demo-web:85 | 48 minutes ago | RUNNING |       |
    | fb60ba9f | web  | demo-web:85 | 45 minutes ago | RUNNING |       |
    +----------+------+-------------+----------------+---------+-------+
