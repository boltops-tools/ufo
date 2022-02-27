describe Ufo::Ecr::Auth do
  let(:repo_domain) { "123456789.dkr.ecr.us-east-1.amazonaws.com" }
  let(:username) { "user" }
  let(:password) { "opensesame" }
  let(:auth) { Ufo::Ecr::Auth.new(repo_domain) }
  before(:each) do
    allow(auth).to receive(:fetch_auth_token).and_return(Base64.encode64("#{username}:#{password}"))
  end

  context("update") do
    context("with ecr repo") do
      context("when login successful") do
        it "should create the auth token" do
          command = "docker login -u #{username} --password-stdin #{repo_domain}"
          command_result = double(success?: true)
          expect(Open3).to receive(:capture3)
            .with(command, stdin_data: password)
            .and_return(['', '', command_result])

          auth.update
        end
      end

      context("when login failed") do
        it "should exit with code 1" do
          command = "docker login -u #{username} --password-stdin #{repo_domain}"
          command_result = double(success?: false)
          expect(Open3).to receive(:capture3)
            .with(command, stdin_data: password)
            .and_return(['', '', command_result])
          expect(auth).to receive(:exit).with(1)

          auth.update
        end
      end
    end

    context("with not ecr repo") do
      let(:repo_domain) { "example/test" }

      it "should not update credentials" do
        expect(Open3).not_to receive(:capture3)

        auth.update
      end
    end
  end
end
