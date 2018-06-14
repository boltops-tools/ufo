## Examples

    ufo balancer init
    ufo balancer init --subnets subnet-aaa subnet-bbb --vpc-id vpc-123
    ufo balancer init --default-vpc

The `--default-vpc` option will set the `--subnets` and `--vpc-id` option to the default of the region you are in.  This spares you from having to look up the default values manually.
