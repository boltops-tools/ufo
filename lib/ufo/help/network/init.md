## Examples

    ufo network init # will use default vpc and subnets
    ufo network init --vpc-id vpc-123
    ufo network init --vpc-id vpc-123 --subnets subnet-aaa subnet-bbb

If the `--vpc-id` option is set and the `--subnets` is not, then ufo generates files with all the associated subnets from the specified vpc id.

You can also specify name of the settings file to create with the `--filename` option.  Example.

    ufo network init --vpc-id vpc-123 --filename dev

The above command creates a `.ufo/settings/network/dev.yml` file.  You might want to then update your `.ufo/settings.yml` file and update the `network_profile` config to reference it.
