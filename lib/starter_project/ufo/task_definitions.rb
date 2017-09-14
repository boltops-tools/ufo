# There will be some special variables that are automatically available in this file.
#
# Some of variables are from the Dockerfile and some are from other places.
#
# * helper.full_image_name - Docker image name with the tag when docker image is built by ufo. This is defined in ufo/settings.yml.  The helper.full_image_name includes the git sha tongueroo/hi:ufo-[sha].
# * helper.dockerfile_port - Expose port in the Dockerfile.  Only supports one exposed port, the first one that is encountered.
#
# helper.env_vars - is a helper method that generates the proper environment Array of Hashes
#
# More info: http://ufoships.com/docs/helpers/
#
task_definition "<%= @app %>-web" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "web",
    container_port: helper.dockerfile_port,
    awslogs_group: "<%= @app %>-web",
    awslogs_stream_prefix: "<%= @app %>",
    command: ["bin/web"]
  )
end

task_definition "<%= @app %>-worker" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "worker",
    awslogs_group: "<%= @app %>-web",
    awslogs_stream_prefix: "<%= @app %>",
    command: ["bin/worker"]
  )
end

task_definition "<%= @app %>-clock" do
  source "main" # will use ufo/templates/main.json.erb
  variables(
    family: task_definition_name,
    name: "clock",
    awslogs_group: "<%= @app %>-web",
    awslogs_stream_prefix: "<%= @app %>",
    command: ["bin/clock"]
  )
end
