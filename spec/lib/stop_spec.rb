describe Ufo::Stop do
  before(:all) do
    create_ufo_project
  end
  let(:stop) { Ufo::Stop.new("test-web") }
  let(:deployments) { JSON.load(IO.read("spec/fixtures/deployments.json")) }

  it "stop" do
    stop.instance_variable_set(:@deployments, deployments)
    arn = stop.latest_deployed_arn
    expect(arn).to include "demo-web:91"
  end
end
