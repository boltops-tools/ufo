describe Ufo::Apps do
  let(:apps) do
    Ufo::Apps.new({})
  end

  context "running tasks" do
    let(:describe_tasks_response) do
      JSON.load(IO.read("spec/fixtures/apps/describe_services.json"))
    end
    it "displays info" do
      allow(apps).to receive(:service_info).and_return([
        "demo-web", "task-def", "1", "EC2", "yes"
      ])
      apps.display_info(describe_tasks_response)
    end
  end
end
