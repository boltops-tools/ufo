## Examples

To run a one time task with ECS:

  ufo task hi-migrate

You can also override the command used by the Docker container in the task definitions via command.

  ufo task hi-web --command bin/migrate
  ufo task hi-web --command bin/with_env bundle exec rake db:migrate:redo VERSION=xxx
