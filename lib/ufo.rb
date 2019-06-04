$stdout.sync = true unless ENV["UFO_STDOUT_SYNC"] == "0"

$:.unshift(File.expand_path('../', __FILE__))
require 'deep_merge'
require 'fileutils'
require 'memoist'
require 'rainbow/ext/string'
require 'render_me_pretty'
require 'ufo/version'

module Ufo
  autoload :Apps, 'ufo/apps'
  autoload :AwsService, 'ufo/aws_service'
  autoload :Base, 'ufo/base'
  autoload :Cancel, 'ufo/cancel'
  autoload :CLI, 'ufo/cli'
  autoload :Command, 'ufo/command'
  autoload :Completer, "ufo/completer"
  autoload :Completion, "ufo/completion"
  autoload :Core, 'ufo/core'
  autoload :Current, 'ufo/current'
  autoload :Destroy, 'ufo/destroy'
  autoload :Docker, 'ufo/docker'
  autoload :DSL, 'ufo/dsl'
  autoload :Ecr, 'ufo/ecr'
  autoload :ECS, 'ufo/ecs'
  autoload :Help, 'ufo/help'
  autoload :Info, 'ufo/info'
  autoload :Init, 'ufo/init'
  autoload :LogGroup, 'ufo/log_group'
  autoload :Network, 'ufo/network'
  autoload :Param, 'ufo/param'
  autoload :Ps, 'ufo/ps'
  autoload :Releases, 'ufo/releases'
  autoload :Rollback, 'ufo/rollback'
  autoload :Scale, 'ufo/scale'
  autoload :Sequence, 'ufo/sequence'
  autoload :Setting, 'ufo/setting'
  autoload :Ship, 'ufo/ship'
  autoload :Stack, 'ufo/stack'
  autoload :Status, 'ufo/status'
  autoload :Stop, 'ufo/stop'
  autoload :Task, 'ufo/task'
  autoload :Tasks, 'ufo/tasks'
  autoload :TemplateScope, 'ufo/template_scope'
  autoload :Upgrade, "ufo/upgrade"
  autoload :Util, 'ufo/util'

  extend Core
end

Ufo.set_aws_profile!
