# There some built-in helpers that are automatically available in this file.
#
# Some of helpers get data from the Dockerfile and some are from other places.
# Here's a summary of the some helpers:
#
#   helper.full_image_name 
#   helper.dockerfile_port
#   helper.env_vars(text)
#   helper.env_file(path)
#   helper.current_region
#
# More info: http://ufoships.com/docs/helpers/
#
task_definition "<%= @app %>-web" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "web",
    container_port: helper.dockerfile_port,
    # Comment out awslogs_* if you do not want logs to be sent to CloudWatch.
    # Strongly recommended to use CloudWatch/centralized logging.
    # Ufo automatically creates the log group as part of deployment.
    awslogs_group: "ecs/<%= @app %>-web",
    awslogs_stream_prefix: "<%= @app %>",
    awslogs_region: current_region,
    # command: ["bin/web"] # IMPORTANT: change or create a bin/web file
  )
end

task_definition "<%= @app %>-worker" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "worker",
    # Comment out awslogs_* if you do not want logs to be sent to CloudWatch.
    awslogs_group: "ecs/<%= @app %>-worker",
    awslogs_stream_prefix: "<%= @app %>",
    awslogs_region: current_region,
    # command: ["bin/worker"] # IMPORTANT: change or create a bin/worker file
  )
end

task_definition "<%= @app %>-clock" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "clock",
    # Comment out awslogs_* if you do not want logs to be sent to CloudWatch.
    awslogs_group: "ecs/<%= @app %>-clock",
    awslogs_stream_prefix: "<%= @app %>",
    awslogs_region: current_region,
    # command: ["bin/clock"] # IMPORTANT: change or create a bin/clock file
  )
end
