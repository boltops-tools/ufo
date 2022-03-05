github_url("https://github.com/boltops-tools/ufo")
linux_image("aws/codebuild/amazonlinux2-x86_64-standard:3.0")
environment_variables(
  DOCKER_USER: "ssm:/codebuild/ufo/DOCKER_USER",
  DOCKER_PASS: "ssm:/codebuild/ufo/DOCKER_PASS",
)

# triggers(
#   webhook: true,
#   filter_groups: [[{type: "EVENT", pattern: "PUSH"}]]
# )
