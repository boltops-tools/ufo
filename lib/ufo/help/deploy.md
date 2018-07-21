It is useful to sometimes deploy only the task definition without re-building it.  Say for example, you are debugging the task definition and just want to directly edit the `.ufo/output/demo-web.json` definition. You can accomplish this with the `ufo deploy` command.  The `ufo deploy` command will deploy the task definition in `.ufo/output` unmodified.  Example:

    ufo deploy demo-web

The above command does the following:

1. register the `.ufo/output/demo-web.json` task definition to ECS untouched.
2. deploys it to ECS by updating the service

## ufo tasks build

To regenerate a `.ufo/output/demo-web.json` definition:

    ufo tasks build

## ufo ship

The `ufo deploy` command does less than the `ufo ship` command.  Normally, it is recommended to use `ufo ship` over the `ufo deploy` command to do everything in one step:

1. build the Docker image
2. register the ECS task definition
3. update the ECS service

The `ufo ships`, `ufo ship`, `ufo deploy` command support the same options. The options are presented here again for convenience:

{% include ufo-ship-options.md %}

## Creating mutiple environments in parallel

If you would like to create multiple enviroments quickly in parallel, the `--no-wait` and `--build` option can help speed up the process.  Example:

    ufo ship # at least once
    for i in {1..3}; do
      UFO_ENV_EXTRA=$i ufo deploy --no-wait --build
    done

A more detailed post is available here: [How to Create Unlimited Extra Environments
](https://blog.boltops.com/2018/07/12/ufo-how-to-create-unlimited-extra-environments).
