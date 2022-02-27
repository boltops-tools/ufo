ENV["UFO_TEST"] = "1"
# Ensures aws api never called. Fixture home does not contain ~/.aws/credentials
ENV['HOME'] = "spec/fixtures/home"

require "pp"
require "byebug"
root = File.expand_path("../", File.dirname(__FILE__))
require "#{root}/lib/ufo"

module Helpers
  def execute(cmd)
    show_command = ENV['DEBUG'] || ENV['SHOW_COMMAND']
    puts "Running: #{cmd}" if show_command
    out = `#{cmd}`
    puts out if show_command
    out
  end
end

RSpec.configure do |c|
  c.include Helpers
end
