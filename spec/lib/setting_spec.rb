describe Ufo::Setting do
  before(:all) do
    create_ufo_project
  end

  let(:setting) { Ufo::Setting.new }

  it "includes base into other environments automatically" do
    count = settings["new_service"]["desired_count"]
    expect(count).to eq 1
  end
end
