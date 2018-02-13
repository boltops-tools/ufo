describe Ufo::Core do
  before(:all) do
    create_starter_project_fixture
  end

  it "finds the first that contains the aws profile" do
    env = Ufo.send(:env_from_profile, "aws_dev_profile1")
    expect(env).to eq "development"
    env = Ufo.send(:env_from_profile, "aws_dev_profile2")
    expect(env).to eq "development"
    env = Ufo.send(:env_from_profile, "aws_prod_profile")
    expect(env).to eq "production"
    env = Ufo.send(:env_from_profile, "does_not_exist")
    expect(env).to be nil
  end
end
