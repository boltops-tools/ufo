module Ufo
  class Names
    extend Memoist
    include Ufo::TaskDefinition::Helpers::AwsHelper

    attr_reader :role
    def initialize
      @role = Ufo.role
    end

    def cluster
      expansion(Ufo.config.ecs.cluster) # IE: :ENV => dev
    end
    memoize :cluster

    # Examples:
    # When UFO_EXTRA not set: :APP-:ROLE-:ENV-:EXTRA => demo-web-dev
    # When UFO_EXTRA=1:       :APP-:ROLE-:ENV-:EXTRA => demo-web-dev-2
    def stack
      expansion(Ufo.config.names.stack) # IE: :APP-:ROLE-:ENV => demo-web-dev
    end
    memoize :stack

    # Examples:
    # When UFO_EXTRA not set: :APP-:ROLE-:ENV-:EXTRA => demo-web-dev
    # When UFO_EXTRA=1:       :APP-:ROLE-:ENV-:EXTRA => demo-web-dev-2
    def task_definition
      expansion(Ufo.config.names.task_definition) # IE: :APP-:ROLE-:ENV => demo-web-dev
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
