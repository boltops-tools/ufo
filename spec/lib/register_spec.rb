describe Ufo::Tasks::Register do
  before(:all) do
    create_ufo_project
  end

  let(:register) { Ufo::Tasks::Register.new("fake_task_definition_path") }

  context "syslog" do
    let(:data) do
      {
        "container_definitions": [{
          "logConfiguration": {
            "logDriver": "syslog"
          }
        }]
      }.to_snake_keys.deep_symbolize_keys
    end

    it "dasherizes log configuration option" do
      register.dasherize_log_configuation_option(data)
    end
  end

  context "awslogs" do
    let(:data) do
      {
        "container_definitions": [{
          "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
              "awslogs-group": "mygroup",
              "awslogs-region": "us-east-1",
              "awslogs-stream-prefix": "mystream"
            }
          }
        }]
      }.to_snake_keys.deep_symbolize_keys
    end

    it "dasherizes log configuration option" do
      register.dasherize_log_configuation_option(data)
    end
  end
end
