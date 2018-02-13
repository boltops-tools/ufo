describe Ufo::Ecr::Auth do
  let(:repo_domain) { "123456789.dkr.ecr.us-east-1.amazonaws.com" }
  let(:auth) { Ufo::Ecr::Auth.new(repo_domain) }
  before(:each) do
    allow(auth).to receive(:fetch_auth_token).and_return("opensesame")
  end

  context("update") do
    before(:each) do
      clean_home
    end

    context("missing ~/.docker/config.json") do
      it "should create the auth token" do
        auth.update
        data = JSON.load(IO.read("spec/fixtures/home/.docker/config.json"))
        auth_token = data["auths"][repo_domain]["auth"]
        expect(auth_token).to eq("opensesame")
      end
    end

    context("existing ~/.docker/config.json") do
      it "should update the auth token" do
        auth.update
        data = JSON.load(IO.read("spec/fixtures/home/.docker/config.json"))
        auth_token = data["auths"][repo_domain]["auth"]
        expect(auth_token).to eq("opensesame")
      end
    end
  end

  def clean_home
    FileUtils.rm_rf("spec/fixtures/home")
    FileUtils.cp_r("spec/fixtures/home_existing", "spec/fixtures/home")
  end
end
