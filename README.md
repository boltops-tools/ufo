# Ufo - A Easy Way to Build and Ship Docker Images AWS ECS

[![CircleCI](https://circleci.com/gh/tongueroo/ufo.svg?style=svg)](https://circleci.com/gh/tongueroo/ufo)

## Quick Introduction

Ufo is a simple tool that makes building and shipping Docker containers to [AWS ECS](https://aws.amazon.com/ecs/) super easy.

* This blog post provides an introduction to the tool: [Ufo - Build Docker Containers and Ship Them to AWS ECS](https://medium.com/@tongueroo/ufo-easily-build-docker-containers-and-ship-them-to-aws-ecs-15556a2b39f#.qqu8o4wal).
* This presentation covers ufo also: [Ufo Ship on AWS ECS](http://www.slideshare.net/tongueroo/ufo-ship-for-aws-ecs-70885296)

A summary of what `ufo ship` does:

1. Builds a docker image. 
2. Generates and registers the ECS template definition. 
3. Deploys the ECS template definition to the specified service.

Ufo deploys a task definition that is created via a template generator which is fully controllable.


## Installation

    $ gem install ufo

### Dependencies

* Docker: You will need a working version of [Docker](https://docs.docker.com/engine/installation/) installed as ufo shells out and calls the `docker` command.
* AWS: Set up your AWS credentials at `~/.aws/credentials` and `~/.aws/config`.  This is the [AWS standard way of setting up credentials](https://aws.amazon.com/blogs/security/a-new-and-standardized-way-to-manage-credentials-in-the-aws-sdks/).

## Quick Usage

### ufo ship

To execute the ship process run:

```bash
ufo ship hi-web-prod --cluster mycluster
```

Note, if you have configured `ufo/settings.yml` to map hi-web-prod to the `mycluster` cluster using the service_cluster option the command becomes simply:

```bash
ufo ship hi-web-prod
```

When you run `ufo ship hi-web-prod`:

1. It builds the docker image.
2. Generates a task definition and registers it.
3. Updates the ECS service to use it.

If the ECS service hi-web-prod does not yet exist, ufo will create the service for you.

By convention, if the service has a container name web, you'll get prompted to create an ELB and specify a target group arn.  The ELB and target group must already exist.

You can bypass the prompt and specify the target group arn as part of the command.  The elb target group can only be associated when the service gets created for the first time.  If the service already exists then the `--target-group` parameter just gets ignored and the ECS task simply gets updated.  Example:


```bash
ufo ship hi-web-prod --target-group=arn:aws:elasticloadbalancing:us-east-1:12345689:targetgroup/hi-web-prod/12345
```

When using ufo if the ECS service does not yet exist, it will automatically be created for you.  Ufo will also automatically create the ECS cluster. If you are relying on this tool to create the cluster, you still need to associate ECS Container Instances to the cluster yourself.

## Detailed Usage

First initialize ufo files within your project.  Let's say you have an example `hi` app.

```
$ git clone https://github.com/tongueroo/hi
$ cd hi
$ ufo init --app hi --cluster stag --image tongueroo/hi
Setting up ufo project...
created: ./bin/deploy
exists: ./Dockerfile
created: ./ufo/settings.yml
created: ./ufo/task_definitions.rb
created: ./ufo/templates/main.json.erb
created: ./.env
Starter ufo files created.
$
```

Take a look at the `ufo/settings.yml` file and notice that it contains some default configuration settings so you do not have to type out these options repeatedly for some of the ufo commands.

```yaml
image: tongueroo/hi
service_cluster:
  default: prod # default cluster
  hi-web-prod: blue
  hi-clock-prod: blue
  hi-worker-prod: blue
```

The `image` value is the name that ufo will use for the Docker image name.

The `service_cluster` mapping provides a way to set default service-to-cluster mappings so that you do not have to specify the `--cluster` repeatedly.  This is very helpful. For example:

```
ufo ship hi-web-prod --cluster hi-cluster
ufo ship hi-web-prod # same as above because it is configured in ufo/settings.yml
ufo ship hi-web-prod --cluster special-cluster # overrides the default setting in `ufo/settings.yml`.
```

### Task Definition ERB Template and DSL Generator

Ufo task definitions are written as an ERB template that makes it every easily accessible and configurable to your requirements.  Here is is an example of an ERB template `ufo/templates/main.json.erb` that shows how easy it is to modfied the task definition you want to be uploaded by ufo:

```json
{
    "family": "<%= @family %>",
    "containerDefinitions": [
        {
            "name": "<%= @name %>",
            "image": "<%= @image %>",
            "cpu": <%= @cpu %>,
            <% if @memory %>
            "memory": <%= @memory %>,
            <% end %>
            <% if @memory_reservation %>
            "memoryReservation": <%= @memory_reservation %>,
            <% end %>
            <% if @container_port %>
            "portMappings": [
                {
                    "containerPort": "<%= @container_port %>",
                    "protocol": "tcp"
                }
            ],
            <% end %>
            "command": <%= @command.to_json %>,
            <% if @environment %>
            "environment": <%= @environment.to_json %>,
            <% end %>
            <% if @awslogs_group %>
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "<%= @awslogs_group %>",
                    "awslogs-region": "<%= @awslogs_region || 'us-east-1' %>",
                    "awslogs-stream-prefix": "<%= @awslogs_stream_prefix %>"
                }
            },
            <% end %>
            "essential": true
        }
    ]
}
```

The instance variable values are specified in `ufo/task_definitions.rb` via a DSL.  Here's the


```ruby
task_definition "hi-web-prod" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    # image: tongueroo/hi:ufo-[timestamp]=[sha]
    image: helper.full_image_name,
    environment: env_file('.env.prod')
    name: "web",
    container_port: helper.dockerfile_port,
    command: ["bin/web"]
  )
end
```

The task\_definitions.rb file has some special variables and helper methods available. These helper methods provide useful contextual information about the project. For example, one of the variable provides the exposed port in the Dockerfile of the project. This why if someone changes the exported port in the Dockerfile, he will not "forgot" to also update the ufo variable as it is automatically referenced. Here is a list of the important helpers:

* **helper.full\_image\_name** — The full docker image name that ufo builds. The “base” portion of the docker image name is defined in ufo/settings.yml. For example, the base portion is `tongueroo/hi` and the full image name is `tongueroo/hi:ufo-[timestamp]-[sha]`. The base name does not include the generated Docker tag, which contains a timestamp and git sha of the Dockerfile that is used.
* **helper.dockerfile\_port** — Exposed port extracted from the Dockerfile of the project. 
* **env_vars(text)** — This method takes a block of text that contains the env values in key=value format and converts that block of text to the proper task definition json format.
* **env_file(path)** — This method takes an `.env` file which contains a simple key value list of environment variables and converts the list to the proper task definition json format.

The 2 classes which provide these special helper methods are in [ufo/dsl.rb](https://github.com/tongueroo/ufo/blob/master/lib/ufo/dsl.rb) and [ufo/dsl/helper.rb](https://github.com/tongueroo/ufo/blob/master/lib/ufo/dsl/helper.rb). Refer to these classes for the full list of the special variables and methods.

### Shipping Multiple Services with bin/deploy

A common pattern is to have 3 processes: web, worker, and clock.  This is very common in rails applcations. The web process handles web traffic, the worker process handles background job processing that would be too slow and potentially block web requests, and a clock process is typically used to schedule recurring jobs. These processes use the same codebase, or same docker image, but have slightly different run time settings.  For example, the docker run command for a web process could be [puma](http://puma.io/) and the command for a worker process could be [sidekiq](http://sidekiq.org/).  Environment variables are sometimes different also.  The important key is that the same docker image is used for all 3 services but the task definition for each service is different.

This is easily accomplished with the `bin/deploy` wrapper script that the `ufo init` command initially generates.  The starter script example shows you how you can use ufo to generate one docker image and use the same image to deploy to all 3 services.  Here is an example `bin/deploy` script:

```bash
#!/bin/bash -xe

ufo ship hi-worker-prod --cluster stag --no-wait
ufo ship hi-clock-prod --cluster stag --no-wait --no-docker
ufo ship hi-web-prod --cluster stag --no-docker
```

The first `ufo ship hi-worker-prod` command build and ships docker image to ECS, but the following two `ufo ship` commands use the `--no-docker` flag to skip the `docker build` step.  `ufo ship` will use the last built docker image as the image to be shipped.  For those curious, this is stored in `ufo/docker_image_name_ufo.txt`.

### Service and Task Names Convention

Ufo assumes a convention that service\_name and the task\_name are the same.  If you would like to override this convention then you can specify the task name.

```
ufo ship hi-web-prod--task my-task
```

This means that in the task_definition.rb you will also defined it with `my-task`.  For example:

```ruby
task_definition "my-task" do
  source "web" # this corresponds to the file in "ufo/templates/web.json.erb"
  variables(
    family: "my-task",
    ....
  )
end

```

### Running Tasks in Pieces

The `ufo ship` command goes through a few stages: building the docker image, registering the task defiintions and updating the ECS service.  The CLI exposes each of the steps as separate commands.  Here is now you would be able to run each of the steps in pieces.

Build the docker image first.

```bash
ufo docker build
ufo docker build --push # will also push to the docker registry
```

Build the task definitions.

```bash
ufo tasks build
ufo tasks register # will register all genreated task definitinos in the ufo/output folder
```

Skips all the build docker phases of a deploy sequence and only update the service with the task definitions.

```bash
ufo ship hi-web-prod--no-docker
```
Note if you use the `--no-docker` option you should ensure that you have already push a docker image to your docker register.  Or else the task will not be able to spin up because the docker image does not exist.  I recommend that you normally use `ufo ship` most of the time.


### Automated Docker Images Clean Up

Ufo can be configured to automatically clean old images from the ECR registry after the deploy completes.  I normally set `~/.ufo/settings.yml` like so:

```yaml
ecr_keep: 30
```

Automated Docker images clean up only works if you are using ECR registry.

## Running a single task

Sometimes you do not want to run a long running `service` but a one time task. Running Rails migrations are a good example of a one off task.  Here is an example of how you would run a one time task.

```
ufo task hi-migrate-prod
```

You will need to define a task definition for the migrate command also in `ufo/task_definitions.rb`.  If you only need to override the Docker command and can re-use an existing task definition like `hi-web-prod`.  You can use the `--command` option:

```
ufo task hi-web-prod --command bin/migrate
ufo task hi-web-prod --command bin/with_env bundle exec rake db:migrate:redo VERSION=xxx
```

The `--command` option takes a string. If the string has brackets in it then it will be evaluated as an Array but the option must be a string.

## Scale

There is a convenience wrapper that simple executes `aws ecs update-service --service [SERVICE] --desired-count [COUNT]`

```
ufo scale hi-web 1
```

## Destroy

To scale down the service and destroy it:

```
ufo destroy hi-web
```

### More Help

```
ufo help
```
## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/tongueroo/ufo/issues](https://github.com/tongueroo/ufo/issues).
