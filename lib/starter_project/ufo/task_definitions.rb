# There some built-in helpers that are automatically available in this file.
#
# Some of helpers get data from the Dockerfile and some are from other places.
# Here's a summary of the some helpers:
#
#   full_image_name 
#   dockerfile_port
#   env_vars(text)
#   env_file(path)
#
# More info: http://ufoships.com/docs/helpers/
#
task_definition "<%= @app %>-web" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "web",
    container_port: helper.dockerfile_port,
    # uncomment out to set the log group
    # awslogs_group: "<%= @app %>-web",
    # awslogs_stream_prefix: "<%= @app %>",
    # awslogs_region: "us-east-1",
    command: ["bin/web"]
  )
end

task_definition "<%= @app %>-worker" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "worker",
    # uncomment out to set the log group
    # awslogs_group: "<%= @app %>-worker",
    # awslogs_stream_prefix: "<%= @app %>",
    # awslogs_region: "us-east-1",
    command: ["bin/worker"]
  )
end

task_definition "<%= @app %>-clock" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "clock",
    # uncomment out to set the log group
    # awslogs_group: "<%= @app %>-clock",
    # awslogs_stream_prefix: "<%= @app %>",
    # awslogs_region: "us-east-1",
    command: ["bin/clock"]
  )
end
