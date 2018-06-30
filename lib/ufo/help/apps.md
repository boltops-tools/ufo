This command lists ECS services for an ECS cluster. It includes ECS services that were not created by ufo also.  A `Ufo?` column value of `yes` indicates that the ECS service was created by ufo version 4 and above.  If the service was created with ufo version 3 and below then it will show up as `no`.

## Examples

    $ ufo apps
    Listing ECS services in the development cluster.
    +--------------------------------------------------+-----------------+---------+-------------+------+
    |                   Service Name                   | Task Definition | Running | Launch type | Ufo? |
    +--------------------------------------------------+-----------------+---------+-------------+------+
    | development-demo-web-Ecs-7GAUAXH5F56M (demo-web) | demo-web:85     | 2       | FARGATE     | yes  |
    +--------------------------------------------------+-----------------+---------+-------------+------+
    $
