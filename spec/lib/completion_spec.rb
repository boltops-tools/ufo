require 'spec_helper'

describe Ufo::CLI do
  describe "ufo completion" do
    commands = {
      "hell" => "hello",
      "hello" => "name",
      "hello -" =>  "--from",
      "hello name" => "--from",
      "hello name --" => "--from",
      "sub goodb" => "goodbye",
      "sub goodbye" => "name",
      "sub goodbye name" => "--from",
      "sub goodbye name --" => "--from",
      "sub goodbye name --from" => "--help",
    }
    commands.each do |command, expected_word|
      it "#{command}" do
        out = execute("exe/ufo completion #{command}")
        expect(out).to include(expected_word) # only checking for one word for simplicity
      end
    end
  end
end
