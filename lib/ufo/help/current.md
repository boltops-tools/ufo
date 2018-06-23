Sets the current service that you're working with you do not have to provide the service name for other commands.

Simply writes to a `.ufo/current` file with the service specified.

## Examples

To set current service:

    ufo current --service hi-web
    ufo current --service hi-worker
    ufo current --service demo-web

To view current service, run `ufo current` without any arguments.

    $ ufo current
    Current service: hi-web

To remove current service:

    ufo current --service ''

To remove all current settings use the `--rm` option.

    ufo current --rm

### UFO_ENV_EXTRA

To also set a current UFO_ENV_EXTRA.

    ufo current --env-extra 1

The extra env setting will be reflected:

    $ ufo current
    Current service: hi-web
    Current env_extra: 1

To unset:

    ufo current --env-extra ''
