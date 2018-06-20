describe Ufo::Ps do
  let(:ps) do
    Ufo::Ps.new("test-web", {})
  end

  context "running tasks" do
    let(:describe_tasks_response) do
      JSON.load(IO.read("spec/fixtures/ps/describe_tasks_response.json"))
    end
    it "displays info" do
      ps.display_info(describe_tasks_response)
    end
  end
end
