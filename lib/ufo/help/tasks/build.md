## Summarized Example

    ufo tasks build

Builds all the task defintiions. Note all the existing ufo/output generated task defintions are wiped out.

## Explanation

The command `ufo tasks build` generates the task definitions locally and writes them to the `output/` folder.  There are 2 files that it uses in order to produce the raw AWS task definitions files.

1. ufo/templates/main.json.erb
2. ufo/task_definitions.rb

Here's an example of each of them:

**main.json.erb**:

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

**task_definitions.rb**:

```ruby
task_definition "hi-web" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "web",
    container_port: helper.dockerfile_port,
    command: ["bin/web"]
  )
end

task_definition "hi-worker" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "worker",
    command: ["bin/worker"]
  )
end

task_definition "hi-clock" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "clock",
    command: ["bin/clock"]
  )
end
```

The shared variables are set in the variables folder:

**ufo/variables/base.rb**:

```ruby
@image = helper.full_image_name # includes the git sha tongueroo/hi:ufo-[sha].
@cpu = 128
@memory_reservation = 256
@environment = helper.env_file(".env")
```

**ufo/variables/production.rb**:

```ruby
@environment = helper.env_vars(%Q{
  RAILS_ENV=production
  SECRET_KEY_BASE=secret
})
```

Ufo combines the `main.json.erb` template, `task_definitions.rb` definitions, and variables in the `.ufo/variables` folder.  It then generates the raw AWS formatted task definition in the `output` folder.

To build the task definitions:

    ufo tasks build

You should see output similar to below:

    $ ufo tasks build
    Building Task Definitions...
    Generating Task Definitions:
      ufo/output/hi-web.json
      ufo/output/hi-worker.json
      ufo/output/hi-clock.json
    Task Definitions built in ufo/output.
    $

Let's take a look at one of the generated files: `.ufo/output/hi-web.json`.

    {
      "family": "hi-web",
      "containerDefinitions": [
        {
          "name": "web",
          "image": "tongueroo/hi:ufo-2017-06-11T22-22-32-a18aa30",
          "cpu": 128,
          "memoryReservation": 256,
          "portMappings": [
            {
              "containerPort": "3000",
              "protocol": "tcp"
            }
          ],
          "command": [
            "bin/web"
          ],
          "environment": [
            {
              "name": "RAILS_ENV",
              "value": "staging"
            }
          ],
          "essential": true
        }
      ]
    }

If you need to modify the task definition template to suite your own needs it is super simple, just edit `main.json.erb`.  No need to dive deep into internal code that builds up the task definition with some internal structure.  It is all there for you to fully control.

