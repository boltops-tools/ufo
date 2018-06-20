Sets the current service that you're working with you do not have to provide the service name for other commands.

Simply writes to a `.ufo/current` file with the service specified.

## Examples

To set current service:

    ufo current hi-web
    ufo current hi-worker
    ufo current demo-web

To view current service, run `ufo current` without any arguments.

    $ ufo current
    Current service is set to: hi-web

To unset the current environment use the `--unset` option.

    ufo current --unset
