require 'pathname'
require 'yaml'

module Ufo
  module Core
    extend Memoist

    def check_task_definition!(task_definition)
      task_definition_path = "#{Ufo.root}/.ufo/output/#{task_definition}.json"
      unless File.exist?(task_definition_path)
        puts "ERROR: Unable to find the task definition at #{task_definition_path}.".color(:red)
        puts "Are you sure you have defined it in ufo/template_definitions.rb and it has been generated correctly in .ufo/output?".color(:red)
        puts "If you are calling `ufo deploy` directly, you might want to generate the task definition first with `ufo tasks build`."
        exit
      end
    end

    def root
      path = ENV['UFO_ROOT'] || '.'
      Pathname.new(path)
    end

    def env
      # 2-way binding
      ufo_env = env_from_profile || 'development'
      ufo_env = ENV['UFO_ENV'] if ENV['UFO_ENV'] # highest precedence
      ufo_env
    end
    memoize :env

    def env_extra
      env_extra = Current.env_extra
      env_extra = ENV['UFO_ENV_EXTRA'] if ENV['UFO_ENV_EXTRA'] # highest precedence
      return if env_extra&.empty?
      env_extra
    end
    memoize :env_extra

    # Overrides AWS_PROFILE based on the Ufo.env if set in configs/settings.yml
    # 2-way binding.
    def set_aws_profile!
      return if ENV['TEST']
      return unless File.exist?("#{Ufo.root}/.ufo/settings.yml") # for rake docs
      return unless settings # Only load if within Ufo project and there's a settings.yml
      data = settings[Ufo.env] || {}
      if data["aws_profile"]
        puts "Using AWS_PROFILE=#{data["aws_profile"]} from UFO_ENV=#{Ufo.env} in config/settings.yml"
        ENV['AWS_PROFILE'] = data["aws_profile"]
      end
    end

    def settings
      Setting.new.data
    end
    memoize :settings

    def cfn_profile
      settings[:cfn_profile] || "default"
    end

    def check_ufo_project!
      check_path = "#{Ufo.root}/.ufo/settings.yml"
      unless File.exist?(check_path)
        puts "ERROR: No settings file at #{check_path}.  Are you sure you are in a project with ufo setup?".color(:red)
        puts "Current directory: #{Dir.pwd}"
        puts "If you want to set up ufo for this prjoect, please create a settings file via: ufo init"
        exit 1 unless ENV['TEST']
      end
    end

  private
    def env_from_profile
      Ufo::Setting.new.ufo_env
    end
  end
end
