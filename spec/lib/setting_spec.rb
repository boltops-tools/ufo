describe Ufo::Setting do
  before(:all) do
    create_starter_project_fixture
  end

  let(:setting) { Ufo::Setting.new }

  it "includes base into other environments automatically" do
    count = setting.data["new_service"]["desired_count"]
    expect(count).to eq 1
  end
end
