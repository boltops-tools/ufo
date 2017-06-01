$:.unshift(File.expand_path("../", __FILE__))
require "ufo/version"
require "pp"
require 'deep_merge'
require "colorize"

module Ufo
  autoload :Command, 'ufo/command'
  autoload :Settings, 'ufo/settings'
  autoload :PrettyTime, 'ufo/pretty_time'
  autoload :Execute, 'ufo/execute'
  autoload :Init, 'ufo/init'
  autoload :EcrAuth, 'ufo/ecr_auth'
  autoload :CLI, 'ufo/cli'
  autoload :DockerBuilder, 'ufo/docker_builder'
  autoload :DockerfileUpdater, 'ufo/dockerfile_updater'
  autoload :DockerCleaner, 'ufo/docker_cleaner'
  autoload :TasksBuilder, 'ufo/tasks_builder'
  autoload :TasksRegister, 'ufo/tasks_register'
  autoload :Ship, 'ufo/ship'
  autoload :Task, 'ufo/task'
  autoload :EcrCleaner, 'ufo/ecr_cleaner'
  autoload :Destroy, 'ufo/destroy'
  autoload :Scale, 'ufo/scale'
  # modules
  autoload :Defaults, 'ufo/defaults'
  autoload :AwsServices, 'ufo/aws_services'
end
