describe Ufo::CLI::Logs do
  let(:logs) do
    logs = Ufo::CLI::Logs.new
    allow(logs).to receive(:exit).and_return(null)
    allow(logs).to receive(:info).and_return(null)
    allow(logs).to receive(:ecs).and_return(ecs)
    logs
  end
  let(:ecs) do
    ecs = double(:ecs).as_null_object
    allow(ecs).to receive(:describe_task_definition).and_return(mock_response(fixture))
    ecs
  end
  let(:null) { double(:null).as_null_object }

  context "awslogs conf" do
    let(:fixture) { "spec/fixtures/mocks/logs/awslogs.json" }
    it "find_log_group_name" do
      log_group_name = logs.find_log_group_name
      expect(log_group_name).to eq({"awslogs-group" => "ecs/demo-web", "awslogs-region" => "us-west-2", "awslogs-stream-prefix" => "demo" })
    end
  end

  context "not a awslogs conf" do
    let(:fixture) { "spec/fixtures/mocks/logs/no-awslogs.json" }
    it "find_log_group_name" do
      log_group_name = logs.find_log_group_name
      expect(log_group_name).to be nil
    end
  end

  def mock_response(file)
    data = JSON.load(IO.read(file))

    td = data["task_definition"]
    container_definitions = td["container_definitions"].map do |c|
      l = c["log_configuration"]
      log_configuration = Aws::ECS::Types::LogConfiguration.new(
        log_driver: l["log_driver"],
        options: l["options"],
      )
      Aws::ECS::Types::ContainerDefinition.new(
        name: c["name"],
        log_configuration: log_configuration,
      )
    end
    task_definition = Aws::ECS::Types::TaskDefinition.new(
      task_definition_arn: td["task_definition_arn"],
      container_definitions: container_definitions,
    )
    Aws::ECS::Types::DescribeTaskDefinitionResponse.new(
      task_definition: task_definition,
    )
  end
end
