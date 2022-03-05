## Example

Here's an example:

    ufo ship

Let's deploy

    ufo ship

You will be prompted to confirm before deployment.

    $ ufo ship
    Will deploy stack demo-web-dev (y/N) y

Confirm to ship:

    Will deploy stack demo-web-dev (y/N) y
    Building Docker Image
    => docker build -t 536766270177.dkr.ecr.us-west-2.amazonaws.com/demo:ufo-2022-03-02T20-32-33-12dc6e0 -f Dockerfile .
    Docker Image built: 536766270177.dkr.ecr.us-west-2.amazonaws.com/demo:ufo-2022-03-02T20-32-33-12dc6e0
    Pushing Docker Image
    => docker push 536766270177.dkr.ecr.us-west-2.amazonaws.com/demo:ufo-2022-03-02T20-32-33-12dc6e0
    Task Definition built: .ufo/output/task_definition.json
    Parameters built:      .ufo/output/params.json
    Template built:        .ufo/output/template.yml
    Creating stack demo-web-dev
    Waiting for stack to complete
    08:32:39PM CREATE_IN_PROGRESS AWS::CloudFormation::Stack demo-web-dev User Initiated
    08:34:32PM CREATE_IN_PROGRESS AWS::ECS::Service EcsService
    ...
    08:35:08PM CREATE_COMPLETE AWS::CloudFormation::Stack demo-web-dev
    Stack success status: CREATE_COMPLETE
    Time took: 2m 32s
    Software shipped!
    $

If you want to bypass the prompt.

    ufo ship -y

