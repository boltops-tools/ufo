require 'spec_helper'

describe Ufo::CLI do
  describe "ufo completion" do
    commands = {
      "ship" => "service",
      "ship service" => "--task",
      "docker" =>  "build",
      "docker build" => "--push",
      "docker clean" => "image_name",
      "init" => "--image",
    }
    commands.each do |command, expected_word|
      it "#{command}" do
        out = execute("exe/ufo completion #{command}")
        expect(out).to include(expected_word) # only checking for one word for simplicity
      end
    end
  end
end
