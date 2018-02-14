ENV["TEST"] = "1"
# Ensures aws api never called. Fixture home folder does not contain ~/.aws/credentails
ENV['HOME'] = "spec/fixtures/home"

# CodeClimate test coverage: https://docs.codeclimate.com/docs/configuring-test-coverage
# require 'simplecov'
# SimpleCov.start

require "pp"
require "byebug"
root = File.expand_path("../", File.dirname(__FILE__))
require "#{root}/lib/ufo"

$dest = "tmp/project"
ENV['DEST_ROOT'] = $dest
ENV['UFO_ROOT'] = $dest

module Helpers
  def create_starter_project_fixture
    FileUtils.rm_rf($dest)
    execute("exe/ufo init --app hi --image tongueroo/hi")
    create_test_settings
  end

  # modify the generated settings so we can spec the settings themselves
  def create_test_settings
    FileUtils.cp("spec/fixtures/settings.yml", "#{$dest}/.ufo/settings.yml")
  end

  def execute(cmd)
    puts "Running: #{cmd}" if show_command?
    out = `#{cmd}`
    puts out if show_command?
    out
  end

  # Added SHOW_COMMAND because DEBUG is also used by other libraries like
  # bundler and it shows its internal debugging logging also.
  def show_command?
    ENV['DEBUG'] || ENV['SHOW_COMMAND']
  end
end

RSpec.configure do |c|
  c.include Helpers
end
