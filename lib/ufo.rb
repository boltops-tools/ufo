$:.unshift(File.expand_path('../', __FILE__))
require 'ufo/version'
require 'deep_merge'
require 'colorize'
require 'fileutils'

module Ufo
  autoload :Env, 'ufo/env'
  autoload :Defaults, 'ufo/defaults'
  autoload :AwsService, 'ufo/aws_service'
  autoload :Command, 'ufo/command'
  autoload :Settings, 'ufo/settings'
  autoload :Util, 'ufo/util'
  autoload :Init, 'ufo/init'
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
end

Ufo::Env.setup!
