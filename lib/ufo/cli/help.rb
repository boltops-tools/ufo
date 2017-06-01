module Ufo
  class CLI < Command
    class Help
      class << self
        def init
<<-EOL
Examples:

$ ufo init --cluster prod --image tongueroo/hi --app hi

The image should not include the tag since the tag is generated upon a `ufo ship`.
EOL
        end

        def docker
<<-EOL
Examples:

$ ufo docker build

$ ufo docker tag
EOL
        end

        def docker_base
<<-EOL

The docker cache task builds a docker image using the Dockerfile.base file and
updates the FROM Dockerfile image with the generated image from Dockerfile.base.

Examples:

$ ufo docker base

$ ufo docker base --no-push # do not push the image to the registry

Docker image tongueroo/hi:base-2016-10-21T15-50-57-88071f5 built.
EOL
        end

        def docker_build
<<-EOL
Examples:

$ ufo docker build

$ ufo docker build --push # also pushes the image to the docker registry

Docker image tongueroo/hi:ufo-2016-10-21T15-50-57-88071f5 built.
EOL
        end

        def docker_full_image_name
<<-EOL
Examples:

$ ufo docker full_image_name

Docker image name that will be used: tongueroo/hi:ufo-2016-10-15T19-29-06-88071f5
EOL
        end

        def docker_cleanup
<<-EOL
Examples:

Say you currently have these images:

* tongueroo/hi:ufo-2016-10-15T19-29-06-88071f5

* tongueroo/hi:ufo-2016-10-16T19-29-06-88071f5

* tongueroo/hi:ufo-2016-10-17T19-29-06-88071f5

* tongueroo/hi:ufo-2016-10-18T19-29-06-88071f5

To clean them up and keep the 3 more recent:

$ ufo docker cleanup tongueroo/hi

This will remove tongueroo/hi:ufo-2016-10-15T19-29-06-88071f5.
EOL
        end

        def tasks
<<-EOL
Examples:

$ ufo tasks build

Builds all the task defintiions.

Note all the existing ufo/output generated task defintions are wiped out.
EOL
        end

        def tasks_build
<<-EOL
Examples:

$ ufo tasks build

Builds all the task defintiions.

Note all the existing ufo/output generated task defintions are wiped out.
EOL
        end

        def tasks_register
<<-EOL
Examples:

$ ufo tasks register
All the task defintiions in ufo/output registered.
EOL
        end

        def ship
<<-EOL
Examples:

To build the docker image, generate the task definition and ship it, run:

$ ufo ship hi-web-prod

By convention the task and service names match. If you need override to this convention then you can specific the task.  For example if you want to ship to the `hi-web-prod-1` service and use the `hi-web-prod` task, run:

$ ufo ship hi-web-prod-1 --task hi-web-prod

The deploy will also created the ECS service if the service does not yet exist on the cluster.  The deploy will prompt you for the ELB `--target-group` if you are shipping a web container that does not yet exist.  If it is not a web container the `--target-group` option gets ignored.

The prommpt can be bypassed by specifying a valid `--target-group` option or specifying the `---no-elb-prompt` option.

$ ufo ship hi-web-prod --target-group arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/hi-web-prod/jsdlfjsdkd

$ ufo ship hi-web-prod --no-elb-prompt
EOL
        end

        def task
<<-EOL
Examples:

To run a one time task with ECS:

$ ufo task hi-migrate-prod

You can also override the command used by the Docker container in the task definitions via command.

ufo task hi-web-prod --command bin/migrate

ufo task hi-web-prod --command bin/with_env bundle exec rake db:migrate:redo VERSION=xxx

EOL
        end

        def destroy
<<-EOL
Examples:

Destroys the service.  It will automatcally set the desired task size to 0 and stop all task so the destory happens in one command.

$ ufo destroy hi-web-prod

EOL
        end

        def scale
<<-EOL
Examples:

Scales the service.  Simple wrapper for `aws ecs update-service --service xxx ----desired-count xxx`

$ ufo scale hi-web-prod 5

EOL
        end
      end
    end
  end
end
