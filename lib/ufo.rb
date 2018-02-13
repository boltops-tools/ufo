$:.unshift(File.expand_path('../', __FILE__))
require 'ufo/version'
require 'deep_merge'
require 'colorize'
require 'fileutils'

$:.unshift(File.expand_path("../../vendor/render_me_pretty/lib", __FILE__))
require "render_me_pretty"

module Ufo
  autoload :Core, 'ufo/core'
  autoload :Default, 'ufo/default'
  autoload :AwsService, 'ufo/aws_service'
  autoload :Command, 'ufo/command'
  autoload :Setting, 'ufo/setting'
  autoload :Util, 'ufo/util'
  autoload :Init, 'ufo/init'
  autoload :Sequence, 'ufo/sequence'
  autoload :CLI, 'ufo/cli'
  autoload :Help, 'ufo/help'
  autoload :Ship, 'ufo/ship'
  autoload :Task, 'ufo/task'
  autoload :Destroy, 'ufo/destroy'
  autoload :DSL, 'ufo/dsl'
  autoload :Scale, 'ufo/scale'
  autoload :LogGroup, 'ufo/log_group'

  autoload :Docker, 'ufo/docker'
  autoload :Ecr, 'ufo/ecr'
  autoload :Tasks, 'ufo/tasks'
  autoload :Completion, "ufo/completion"
  autoload :Completer, "ufo/completer"
  autoload :Upgrade3, "ufo/upgrade3"

  extend Core
end

