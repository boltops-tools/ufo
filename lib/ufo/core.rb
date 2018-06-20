require 'pathname'
require 'yaml'

module Ufo
  module Core
    extend Memoist

    def check_task_definition!(task_definition)
      task_definition_path = "#{Ufo.root}/.ufo/output/#{task_definition}.json"
      unless File.exist?(task_definition_path)
        puts "ERROR: Unable to find the task definition at #{task_definition_path}.".colorize(:red)
        puts "Are you sure you have defined it in ufo/template_definitions.rb and it has been generated correctly in .ufo/output?".colorize(:red)
        puts "If you are calling `ufo deploy` directly, you might want to generate the task definition first with `ufo tasks build`."
        exit
      end
    end

    def root
      path = ENV['UFO_ROOT'] || '.'
      Pathname.new(path)
    end

    @@env = nil
    def env
      return @@env if @@env
      ufo_env = env_from_profile(ENV['AWS_PROFILE']) || 'development'
      ufo_env = ENV['UFO_ENV'] if ENV['UFO_ENV'] # highest precedence
      @@env = ufo_env
    end

    def settings
      Setting.new.data
    end
    memoize :settings

    def cfn_profile
      settings["cfn_profile"] || "default"
    end

    private
    # Do not use the Setting class to load the profile because it can cause an
    # infinite loop then if we decide to use Ufo.env from within settings class.
    def env_from_profile(aws_profile)
      data = YAML.load_file("#{Ufo.root}/.ufo/settings.yml")
      env = data.find do |_env, setting|
        setting ||= {}
        profiles = setting['aws_profiles']
        profiles && profiles.include?(aws_profile)
      end
      env.first if env
    end
  end
end
