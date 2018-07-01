describe Ufo::Setting do
  before(:all) do
    create_ufo_project
  end

  let(:setting) { Ufo::Setting.new }

  it "includes the cluster setting" do
    puts "Ufo.env #{Ufo.env}"
    cluster = setting.data[:cluster]
    expect(cluster).to eq "dev"
  end
end
