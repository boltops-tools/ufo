describe Ufo::IamRole::Builder do
  let(:builder) { described_class.new(role_type) }
  let(:role_type) { "task_role" }

  before(:each) do
    Ufo::IamRole::Registry.register_policy("task_role",
      "AmazonS3ReadOnlyAccess",
      {:Action=>["s3:Get*", "s3:List*"], :Effect=>"Allow", :Resource=>"*"}
    )
    Ufo::IamRole::Registry.register_policy("task_role",
      "CloudwatchWrite",
      {:Action=>["cloudwatch:PutMetricData"], :Effect=>"Allow", :Resource=>"*"}
    )
    # Called twice on purpose to show that duplicated items in the set wont create doubles.
    # This allows the Dsl evaluate to be ran multiple times.
    Ufo::IamRole::Registry.register_policy("task_role",
      "CloudwatchWrite",
      {:Action=>["cloudwatch:PutMetricData"], :Effect=>"Allow", :Resource=>"*"}
    )


    Ufo::IamRole::Registry.register_managed_policy("task_role",
      "AmazonS3ReadOnlyAccess", "AmazonEC2ReadOnlyAccess"
    )
  end

  context "build" do
    it "builds role" do
      resource = builder.build
      expected = <<YAML
---
Type: AWS::IAM::Role
Properties:
  AssumeRolePolicyDocument:
    Version: '2012-10-17'
    Statement:
    - Effect: Allow
      Principal:
        Service: ecs-tasks.amazonaws.com
      Action: sts:AssumeRole
  Policies:
  - PolicyName: AmazonS3ReadOnlyAccess
    PolicyDocument:
      Version: '2012-10-17'
      Statement:
      - Action:
        - s3:Get*
        - s3:List*
        Effect: Allow
        Resource: "*"
  - PolicyName: CloudwatchWrite
    PolicyDocument:
      Version: '2012-10-17'
      Statement:
      - Action:
        - cloudwatch:PutMetricData
        Effect: Allow
        Resource: "*"
  ManagedPolicyArns:
  - arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
  - arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
YAML
      yaml = YAML.dump(resource)
      expect(yaml).to eq(expected)
    end
  end
end
