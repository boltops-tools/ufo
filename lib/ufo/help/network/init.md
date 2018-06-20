## Examples

    ufo network init # will use default vpc and subnets
    ufo network init --vpc-id vpc-123
    ufo network init --vpc-id vpc-123 --subnets subnet-aaa subnet-bbb
    ufo network init --launch-type fargate

If the `--vpc-id` option but the `--subnets` is not, then ufo generates files with subnets from the specified vpc id.

The `--launch-type fargate` option generates files with the proper fargate parameters.
