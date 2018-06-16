$:.unshift(File.expand_path('../', __FILE__))
require 'ufo/version'
require 'deep_merge'
require 'colorize'
require 'fileutils'
require 'render_me_pretty'

# adding balancer as submodule for now
$:.unshift(File.expand_path('../../vendor/balancer/lib', __FILE__))
require 'balancer'

module Ufo
  autoload :Balancer, 'ufo/balancer'
  autoload :Core, 'ufo/core'
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
  autoload :ECS, 'ufo/ecs'
  autoload :Param, 'ufo/param'
  autoload :TemplateScope, 'ufo/template_scope'
  autoload :SecurityGroup, 'ufo/security_group'

  autoload :Docker, 'ufo/docker'
  autoload :Ecr, 'ufo/ecr'
  autoload :Tasks, 'ufo/tasks'
  autoload :Completion, "ufo/completion"
  autoload :Completer, "ufo/completer"
  autoload :Upgrade3, "ufo/upgrade3"
  autoload :Upgrade33_to_34, "ufo/upgrade33_to_34"

  extend Core
end

