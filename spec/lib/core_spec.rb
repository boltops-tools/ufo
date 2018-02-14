describe Ufo::Core do
  before(:all) do
    create_ufo_project
  end

  it "finds the first env that contains the aws profile" do
    env = Ufo.send(:env_from_profile, "dev_profile1")
    expect(env).to eq "development"
    env = Ufo.send(:env_from_profile, "dev_profile2")
    expect(env).to eq "development"
    env = Ufo.send(:env_from_profile, "prod_profile")
    expect(env).to eq "production"
    env = Ufo.send(:env_from_profile, "does_not_exist")
    expect(env).to be nil
  end
end
