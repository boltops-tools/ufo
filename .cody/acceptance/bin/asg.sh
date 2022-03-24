function scale_asg_to() {
  n=$1
  ASG=$(asg)
  echo "Scaling $ASG to $n"
  aws autoscaling update-auto-scaling-group --auto-scaling-group-name $ASG \
    --desired-capacity $n --min-size $n --max-size $n
}

# aws cloudformation describe-stacks --stack-name ecs-qa | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "Asg") | .OutputValue'
# aws cloudformation describe-stack-resources --stack-name ecs-qa | jq -r '.StackResources[] | select(.LogicalResourceId == "Asg") | .PhysicalResourceId'
function asg() {
  STACK_NAME=ecs-qa
  ASG=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "Asg") | .OutputValue')
  echo $ASG
}
