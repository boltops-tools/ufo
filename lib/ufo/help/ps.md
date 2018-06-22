## Examples

    $ ufo ps
    => Service: hi-web
       Service name: dev-hi-web-Ecs-17A82H7M463KT
       Status: ACTIVE
       Running count: 1
       Desired count: 1
       Launch type: EC2
       Task definition: hi-web:341
       Dns: dev-hi-Elb-S8ZBDGNPV7SV-5e2dadd7ccdecd8d.elb.us-east-1.amazonaws.com
    +----------+------+------------+----------------+---------+
    |    Id    | Name |  Release   |    Started     | Status  |
    +----------+------+------------+----------------+---------+
    | bf0b183d | web  | hi-web:341 | 13 minutes ago | RUNNING |
    +----------+------+------------+----------------+---------+

Skip the summary info:

    $ ufo ps --no-summary
    +----------+------+------------+----------------+---------+
    |    Id    | Name |  Release   |    Started     | Status  |
    +----------+------+------------+----------------+---------+
    | bf0b183d | web  | hi-web:341 | 13 minutes ago | RUNNING |
    +----------+------+------------+----------------+---------+
