$stdout.sync = true unless ENV["UFO_STDOUT_SYNC"] == "0"

require 'active_support'
require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/delegation'
require 'cli-format'
require 'deep_merge/rails_compat'
require 'dsl_evaluator'
require 'fileutils'
require 'memoist'
require 'rainbow/ext/string'
require 'render_me_pretty'
require 'ufo/ext'
require 'ufo/version'
require 'yaml'

require "ufo/autoloader"
Ufo::Autoloader.setup

module Ufo
  class UfoError < RuntimeError; end
  class ShipmentOverridden < UfoError; end

  extend Core
end

CliFormat.default_format = "table"

Ufo::Booter.boot
