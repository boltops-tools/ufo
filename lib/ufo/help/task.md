## Examples

You can use the `--command` or `-c` option to override the Docker container command.

    ufo task hi-migrate # default command
    ufo task hi-web --command bin/migrate
    ufo task hi-web --command bin/with_env bundle exec rake db:migrate:redo VERSION=xxx
    ufo task hi-web -c uptime
    ufo task hi-web -c pwd

