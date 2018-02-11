require 'spec_helper'

# to run specs with what's remembered from vcr
#   $ rake
#
# to run specs with new fresh data from aws api calls
#   $ rake clean:vcr ; time rake
describe Ufo::CLI do
  before(:all) do
    create_starter_project_fixture
    project_root = File.expand_path("../../fixtures/hi", __FILE__)
    @args = "--noop --project-root=#{project_root}"
  end

  describe "ufo" do
    context "docker" do
      it "build builds image" do
        out = execute("bin/ufo docker build #{@args}")
        expect(out).to include("docker build -t tongueroo/hi")
      end

      it "tag shows the tag" do
        out = execute("bin/ufo docker name #{@args}")
        expect(out).to match(%r{tongueroo/hi:ufo-.{7}})
      end
    end

    context "tasks" do
      it "build builds task definition" do
        out = execute("bin/ufo tasks build #{@args}")
        expect(out).to include("Task Definitions built")
      end

      it "register it registers all the output task definitions" do
        out = execute("bin/ufo tasks register #{@args}")
        expect(out).to include("register")
      end
    end

    context "ship" do
      it "deploys software" do
        out = execute("bin/ufo ship hi-web-prod #{@args} --no-wait")
        # cannot look for Software shipped! because
        #   ship.deploy unless ENV['TEST'] # to allow me to quickly test CLI portion only
        # just testing the CLI portion.  The ship class itself is tested via ship_spec.rb
        expect(out).to include("Task Definitions built")
      end
    end

    context "ships" do
      it "deploys software to multiple services" do
        out = execute("bin/ufo ships hi-web-prod hi-worker-prod #{@args} --no-wait")
        # cannot look for Software shipped! because
        #   ship.deploy unless ENV['TEST'] # to allow me to quickly test CLI portion only
        # just testing the CLI portion.  The ship class itself is tested via ship_spec.rb
        expect(out).to include("Task Definitions built")
      end
    end

    context "task" do
      it "runs one time task" do
        out = execute("bin/ufo completion ship name")
        expect(out).to include("--help")
      end
    end
  end
end
