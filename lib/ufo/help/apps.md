This command lists ECS services for an ECS cluster. It includes ECS services that were not created by ufo also.

## Examples

    $ ufo apps
    Listing ECS services in the dev cluster.
    +-------------------------------------+-----------------+---------+-------------+-----+------+
    |            Service Name             | Task Definition | Running | Launch type | Dns | Ufo? |
    +-------------------------------------+-----------------+---------+-------------+-----+------+
    | dev-hi-web-Ecs-3JCJA3QFYK1 (hi-web) | hi-web:286      | 8       | EC2         |     | yes  |
    +-------------------------------------+-----------------+---------+-------------+-----+------+
