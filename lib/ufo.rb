$stdout.sync = true unless ENV["UFO_STDOUT_SYNC"] == "0"

$:.unshift(File.expand_path('../', __FILE__))
require 'active_support/all'
require 'deep_merge/rails_compat'
require 'fileutils'
require 'memoist'
require 'rainbow/ext/string'
require 'render_me_pretty'
require 'ufo/version'

require "ufo/autoloader"
Ufo::Autoloader.setup

module Ufo
  extend Core
end

Ufo.set_aws_profile!
