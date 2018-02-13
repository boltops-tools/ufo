describe Ufo::Ecr::Cleaner do
  let(:docker_image_name) { "123456789.dkr.ecr.us-east-1.amazonaws.com/my-name" }
  let(:repo_domain) { "https://123456789.dkr.ecr.us-east-1.amazonaws.com" }
  let(:cleaner) do
    Ufo::Ecr::Cleaner.new(docker_image_name,
      project_root: "spec/fixtures/hi",
      ecr_keep: 3, # using 3 to test, default is 30
      mute: true
    )
  end
  before(:each) do
    allow(cleaner).to receive(:update_auth_token).and_return(:whatever)
  end

  context("lots of old images") do
    let(:image_tags) { 10.times.map {|i| "ufo-#{i}" }.reverse }
    before(:each) do
      allow(cleaner).to receive(:fetch_image_tags).and_return(image_tags)
    end

    it "should remove images and keep 3" do
      allow(cleaner).to receive(:ecr).and_return(ecr_stub)
      cleaner.cleanup
      expect(cleaner.ecr).to have_received(:batch_delete_image).with(
          repository_name: "my-name",
          image_ids: [{image_tag: "ufo-6"}, {image_tag: "ufo-5"}, {image_tag: "ufo-4"}, {image_tag: "ufo-3"}, {image_tag: "ufo-2"}, {image_tag: "ufo-1"}, {image_tag: "ufo-0"}]
        )
    end
  end

  def ecr_stub
    ecr = double("Ecr").as_null_object
    allow(ecr).to receive(:batch_delete_image).and_return(:whatever)
    ecr
  end
end
