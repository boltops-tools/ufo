#!/bin/bash

final_status=0
function capture_status {
  if [ "$?" -ne "0" ] && [ $final_status -ne 1 ] ; then
    final_status=1
  fi
}

set -eu
# will build from /tmp because terraspace/Gemfile may interfere
cd /tmp
export PATH=~/bin:$PATH # ~/bin/ufo wrapper

# Create empty folder for project
mkdir demo
cd demo

# Create ECR repo - it might already exist
aws ecr create-repository --repository-name test/demo || true
REPO=$(aws ecr describe-repositories --repository-name test/demo | jq -r '.repositories[].repositoryUri')

# DockerHub
# toomanyrequests: You have reached your pull rate limit. You may increase the limit by authenticating
docker login --username $DOCKER_USER --password $DOCKER_PASS
TOKEN=$(curl -s --user "$DOCKER_USER:$DOCKER_PASS" "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)
echo "Current rate limit:"
curl -s --head -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest

set -x

# Generate .ufo files/structure
ufo init --app testapp --repo $REPO

# Review generated files
cat Dockerfile
cat .ufo/config.rb
cat .ufo/resources/task_definitions/web.yml
cat .ufo/vars/base.rb
cat .ufo/vars/dev.rb

# Deploy
ufo ship -y
# Check
ufo ps
ENDPOINT=$(ufo ps 2>&1 | grep ELB | sed 's/.*ELB: //')
curl -s $ENDPOINT | grep title # should be success. IE: exit 0

# Change
cat << EOF > .ufo/vars/dev.rb
@cpu = 512
@memory = 512
EOF

cat << EOF > .ufo/config/web/dev.rb
Ufo.configure do |config|
  config.autoscaling.max_capacity = 3
end
EOF

# Update
ufo clean -y # dont have to but good to test ufo clean
ufo ship -y
# Check
ufo ps # see full output for debugging
ufo ps 2>&1 | grep 'Max: 3' # should be success. IE: exit 0
# grab task id - json output goes to stdout
TASK=$(ufo ps --format json | jq -r '.[0].Task')
echo "TASK $TASK"

# TODO: create fargate spot cluster
CLUSTER=qa
# Just show for now. Might have to add wait logic to confirm new settings
aws ecs describe-tasks --cluster $CLUSTER --tasks $TASK \
    | jq '.tasks[].containers[] | {cpu: .cpu, memory: .memory}'

# Destroy
ufo destroy -y
# Check
ufo ps
ufo ps 2>&1 | grep No | grep found # should be success. IE: exit 0

## Also test different roles like worker

export UFO_ROLE=worker
ufo ship -y
ufo ps # see full output for debugging
ufo ps 2>&1 | grep Stack | grep worker # should be success. IE: exit 0
ufo destroy -y
ufo ps 2>&1 | grep No | grep found # should be success. IE: exit 0
