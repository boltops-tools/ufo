## Examples

You can use the `--command` or `-c` option to override the Docker container command.

    ufo task hi-migrate # default command
    ufo task demo-web --command bin/migrate
    ufo task demo-web --command bin/with_env bundle exec rake db:migrate:redo VERSION=xxx
    ufo task demo-web -c uptime
    ufo task demo-web -c pwd

## Skipping Docker

The `--no-docker` option is useful. By default, the `ufo task` command will build the docker image.  The docker build process usually is the part that takes the most time. You can skip the docker build process after building it at least once.  This is a faster way to run a bunch of commands with the same Docker image. Example:

  ufo task demo-web -c uptime # build at least once
  ufo task demo-web --no-docker -c ls # skip docker for speed
  ufo task demo-web --no-docker -c pwd # skip docker for speed
