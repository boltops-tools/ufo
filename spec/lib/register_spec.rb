describe Ufo::Tasks::Register do
  before(:all) do
    create_ufo_project
  end

  let(:register) { Ufo::Tasks::Register.new("fake_task_definition_path") }

  context "syslog" do
    let(:data) do
      {
        "containerDefinitions" => [{
          "logConfiguration" => {
            "logDriver" => "syslog"
          }
        }]
      }
    end

    it "#rubyize_format" do
      result = register.rubyize_format(data)
      driver = result[:container_definitions][0][:log_configuration][:log_driver]
      expect(driver).to eq "syslog"
    end
  end

  context "awslogs" do
    let(:data) do
      {
        "containerDefinitions" => [{
          "logConfiguration" => {
            "logDriver" => "awslogs",
            "options" => {
              "awslogs-group" => "mygroup",
              "awslogs-region" => "us-east-1",
              "awslogs-stream-prefix" => "mystream"
            }
          }
        }]
      }
    end

    it "rubyize_format" do
      result = register.rubyize_format(data)
      log_configuration = result[:container_definitions][0][:log_configuration]
      expect(log_configuration[:log_driver]).to eq "awslogs"
      expect(log_configuration[:options].keys).to include("awslogs-group")
    end
  end
end
