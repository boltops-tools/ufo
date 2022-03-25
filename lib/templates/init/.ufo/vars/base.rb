# Example .ufo/vars/base.rb
# Ufo docs
# Variables: http://ufoships.com/docs/variables/
# Helpers: http://ufoships.com/docs/helpers/

@family = family # Also: task_definition_name
@name = role     # IE: web worker clock
@image = docker_image # includes the git sha org/repo:ufo-[sha].
# Docs: https://ufoships.com/docs/helpers/builtin/secrets/
@environment = env_file
@secrets = secrets_file
@cpu = 256
@memory = 256
@memory_reservation = 256

@awslogs_group = expansion("ecs/:APP-:ENV-:EXTRA")
@awslogs_stream_prefix = role
@awslogs_region = aws_region

@container_port = dockerfile_port # parsed from Dockerfile
