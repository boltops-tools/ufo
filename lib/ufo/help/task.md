Examples:

To run a one time task with ECS:

  ufo task hi-migrate-prod

You can also override the command used by the Docker container in the task definitions via command.

  ufo task hi-web-prod --command bin/migrate
  ufo task hi-web-prod --command bin/with_env bundle exec rake db:migrate:redo VERSION=xxx
