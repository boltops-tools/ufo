describe Ufo::Ps do
  let(:ps) do
    Ufo::Ps.new("test-web", {})
  end

  context "running tasks" do
    let(:task_arns) do
      JSON.load(IO.read("spec/fixtures/ps/describe_tasks.json"))["tasks"]
    end
    it "display_tasks" do
      ps.display_tasks(task_arns)
    end
  end
end
