module Ufo
  class Names
    extend Memoist
    include Ufo::TaskDefinition::Helpers::AwsHelper
    include Ufo::Config::CallableOption::Concern

    attr_reader :role
    def initialize
      @role = Ufo.role
    end

    def cluster
      string = callable_option(
        config_name: "ecs.cluster", # Ufo.ecs.cluster => :ENV => dev
        passed_args: [self],
      )
      expansion(string) # IE: :ENV => dev
    end
    memoize :cluster

    # Examples:
    # When UFO_EXTRA not set: :APP-:ROLE-:ENV-:EXTRA => demo-web-dev
    # When UFO_EXTRA=1:       :APP-:ROLE-:ENV-:EXTRA => demo-web-dev-2
    def stack
      string = callable_option(
        config_name: "names.stack", # Ufo.config.names.stack => :APP-:ROLE-:ENV => demo-web-dev
        passed_args: [self],
      )
      expansion(string) # IE: :APP-:ROLE-:ENV => demo-web-dev
    end
    memoize :stack

    # Examples:
    # When UFO_EXTRA not set: :APP-:ROLE-:ENV-:EXTRA => demo-web-dev
    # When UFO_EXTRA=1:       :APP-:ROLE-:ENV-:EXTRA => demo-web-dev-2
    def task_definition
      string = callable_option(
        config_name: "names.task_definition", # Ufo.config.names.task_definition => :APP-:ROLE-:ENV => demo-web-dev
        passed_args: [self],
      )
      expansion(string) # IE: :APP-:ROLE-:ENV => demo-web-dev
    end
    memoize :task_definition

    def expansion(string, options={})
      return string unless string.is_a?(String) # in case of nil

      string = string.dup
      vars = string.scan(/:\w+/) # => [":APP", ":ROLE", :ENV", ":EXTRA"]
      vars.each do |var|
        string.gsub!(var, var_value(var))
      end
      string = strip(string)
      dashes = options[:dasherize].nil? ? true : options[:dasherize]
      string = string.dasherize if dashes
      string
    end

    def var_value(unexpanded)
      name = unexpanded.sub(':','').downcase
      if respond_to?(name)
        send(name).to_s # pass value straight through
      else
        unexpanded
      end
    end

    def strip(string)
      string.sub(/^-+/,'').sub(/-+$/,'') # remove leading and trailing -
            .gsub(%r{-+},'-') # remove double dashes are more. IE: -- => -
    end

    def app
      Ufo.app
    end

    def env
      Ufo.env
    end
    alias_method :ufo_env, :env

    def extra
      Ufo.extra
    end
  end
end
