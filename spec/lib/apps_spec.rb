describe Ufo::Apps do
  let(:apps) do
    Ufo::Apps.new({})
  end

  context "running tasks" do
    let(:describe_tasks_response) do
      JSON.load(IO.read("spec/fixtures/apps/describe_services.json"))
    end
    it "displays info" do
      apps.display_info(describe_tasks_response)
    end
  end
end
