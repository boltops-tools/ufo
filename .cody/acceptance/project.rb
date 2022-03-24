github("boltops-tools/ufo")
image("aws/codebuild/amazonlinux2-x86_64-standard:3.0")
env_vars(
  DOCKER_USER: "ssm:/#{Cody.env}/DOCKER_USER",
  DOCKER_PASS: "ssm:/#{Cody.env}/DOCKER_PASS",
)

# triggers(
#   webhook: true,
#   filter_groups: [[{type: "EVENT", pattern: "PUSH"}]]
# )
