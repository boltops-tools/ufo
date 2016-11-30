# Ufo

This script handles a common application deployment pattern to AWS ECS.  Most rails apps have web, worker, and clock processes. These processes use the same codebase (same docker image) but have slightly different run time settings.  For example, the docker run command for a web process could be `puma` and the command for a worker process could be `sidekiq`.  Environment variables are sometimes different also.

This script builds the same docker image to be used for all of these processes but allows you to different generated AWS ECS Task Definitions for each of the processes.  The task defintions for each process is created via a template generator which you fully can control.

A summary of steps `ufo ship` takes:

1. builds a docker image - optional and can be skipped
2. generates the ecs template definition - optional and can be skipped
3. ships it to possible multiple services depending on the settings

## Installation

    $ gem install ufo

You will need a working version of docker installed if you want ufo to also build the docker image.  If you do not want ufo to build the docker image, then you do not need docker installed.

## Usage

If the cluster or the services do not exist then they get created.  If you are relying on this tool to create the cluster, you still need to associate ECS Container Instances to the cluster yourself.

First initialize ufo files within your project.  Let's say you have an `hi` app.

```
$ cd hi
$ ufo init --cluster default --image tongueroo/hi
Generated starter ufo structure:
hi/ufo/task_definitions.rb
hi/ufo/templates/web.json.erb
hi/ufo/settings.yml # default cluster is saved here
```

It is now a good time to take a look at the generated files at this point.

### ufo/settings.yml

`ufo/settings.yml` holds some default configuration settings so you don't have to type out these options every single time.

```yaml
service_cluster:
  default: my-default-cluster
  hi-web-prod: hi-cluster
image: tongueroo/hi
```

You should adjust the image name if it not already adjusted.

The `service_cluster` mapping provides a way to set default service to cluster mappings so that you do not have to specify the `--cluster` repeatedly.  Example:

```
ufo ship hi-web-prod --cluster hi-cluster
ufo ship hi-web-prod # same as above because it is configured in ufo/settings.yml
ufo ship hi-web-prod --cluster special-cluster # overrides any setting default fallback.
```

### ufo/task_definitions.rb

`ufo/task_definitions.rb` holds the task definitions to be generated.  They correspond to each service you want deployed.  It is written in a DSL.  We'll go over a simplifed example:

```ruby
task_definition "hi-web-prod" do
  source "web" # this corresponds to the file in "ufo/templates/web.json.erb"
            # if source is not set, it will use a default task definition template:
            # https://github.com/tongueroo/ufo/tree/master/lib/ufo/templates/default.json.erb
  variables(
    family: "hi-web-prod",
    name: "web",
    container_port: helper.dockerfile_port,
    command: ["bin/web"]
    image:helper.full_image_name,
    cpu: 2,
    memory_reservation: 128,
    container_port: helper.dockerfile_port,
    command: helper.dockerfile_command,
    environment: [
      {name: "DATABASE_URL", value: "mysql2://user:pass@domani.com:3306/myapp"},
      {name: "PORT", value: helper.dockerfile_port.to_s},
      {name: "SECRET", value: "supersecret"},
    ]
  )
end

```

You'll notice a `helper` variable being used. `helper` is a variable that holds some special variables that is available within the ufo DSL.  They are optional to use.  Here is a list of them:

* helper.full_image_name - Docker image name to be used when a the docker image is build. This is defined in ufo/settings.yml.
* helper.dockerfile_port - Expose port in the Dockerfile.  Only supports one exposed port, the first one that is encountered.

The variables defined within the task_definition block of code are available as instance variables in the corresponding template.  Here is the template with the use of the instance variables:

### ufo/templates/web.json.erb

```html
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
            "essential": true
        }
    ]
}
```

### Customizing Templates

If you want to change the template then you can follow the example in the generated ufo files. For example, if you want to create a template for the worker service.

1. Create a new template under ufo/templates/worker.json.erb.
2. Change the source in the `task_definition` using "worker" as the source.
3. Add variables.

### Ship

Ufo uses the aforementioned files to build task definitions and then ship to them to AWS ECS.  To execute the ship process run:

```bash
ufo ship hi-web-prod
```

When you run `ufo ship hi-web-prod`:

1. It builds the docker image
2. Generates a task definition and registers it
3. Updates the ECS service to use it.

If the ECS service hi-web-prod does not yet exist, ufo will create the service for you.

If the service has a container name web, you'll get prompted to create an ELB and specify a target group arn.  The ELB and target group must already exist.

You can bypass the prompt and specify the target group arn as part of the command.  The elb target group can only be associated when the service gets created for the first time.  If the service already exists then the `--target-group` parameter just gets ignored and the ECS task simply gets updated.


```bash
ufo ship hi-web-prod --target-group=arn:aws:elasticloadbalancing:us-east-1:12345689:targetgroup/hi-web-prod/jdisljflsdkjl
```

### Service and Task Names Convention

Ufo assumes a convention that service\_name and the task\_name are the same.  If you would like to override this convention then you can specify the task name.

```
ufo ship hi-web-prod-1 --task hi-web-prod
```

This means that in the task_definitionintion.rb you will also defined it without the `-1`.  For example:

```ruby
task_definition "hi-web-prod" do
  source "web" # this corresponds to the file in "ufo/templates/web.json.erb"
  variables(
    family: "hi-web-prod",
    ....
  )
end

```

### Running Tasks in Pieces

The `ufo ship` command goes few a few stages: building the docker image, registering the task defiintions and updating the ECS service.  The CLI exposes each of the steps as separate commands.  Here is now you would be able to run each of the steps in pieces.

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
ufo ship hi-web-prod --no-docker
```
Note you use the `--no-docker` option you should make sure you have push a docker image with the previous committed sha code to your docker register.  Or else the task will not be able to spin up because the docker image does not exist.  You can work around this but just running `--no-docker` with a dirty working tree.


## Automatically Creates the Service

When running `ufo ship` if the ECS service does not yet exist, it will automatically be created for you.

## Scale

There is a convenience wrapper that simple executes `aws ecs update-service --service [SERVICE] ----desired-count [COUNT]`

```
ufo scale hi-web-prod 1
```

### More Help

```
ufo help
```
## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/tongueroo/ufo/issues](https://github.com/tongueroo/ufo/issues).

