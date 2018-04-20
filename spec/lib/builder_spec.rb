describe Ufo::Docker::Builder do
  before(:all) do
    create_ufo_project
  end

  let(:builder) { Ufo::Docker::Builder.new }

  context "dockerfile uses ecr image for FROM instruction" do
    it "updates the auth token before building the image" do
      # builder.from_ecr_image?("spec/fixtures/dockerfiles/dockerhub/Dockerfile")
      names = builder.ecr_image_names("spec/fixtures/dockerfiles/ecr/Dockerfile")
      expect(names).not_to be_empty
    end
  end

  context "dockerfile uses dockerhub image for FROM instruction" do
    it "does not update the auth token before building the image" do
      # builder.from_ecr_image?("spec/fixtures/dockerfiles/dockerhub/Dockerfile")
      names = builder.ecr_image_names("spec/fixtures/dockerfiles/dockerhub/Dockerfile")
      expect(names).to be_empty
    end
  end
end
