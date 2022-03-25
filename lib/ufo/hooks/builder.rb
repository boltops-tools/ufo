module Ufo::Hooks
  class Builder
    extend Memoist
    include Dsl
    include DslEvaluator
    include Ufo::Utils::Logging

    attr_accessor :name
    def initialize(options={})
      @options = options
      @file = options[:file] # IE: docker.rb
      @dsl_file = "#{Ufo.root}/.ufo/config/hooks/#{@file}"
      @name = options[:name].to_s
      @hooks = {before: {}, after: {}}
    end

    def build
      evaluate_file(@dsl_file)
      @hooks.deep_stringify_keys!
    end
    memoize :build

    def run_hooks
      build
      run_each_hook("before")
      out = yield if block_given?
      run_each_hook("after")
      out
    end

    def run_each_hook(type)
      hooks = @hooks.dig(type, @name) || []
      hooks.each do |hook|
        run_hook(type, hook)
      end
    end

    def run_hook(type, hook)
      return unless run?(hook)

      id = "#{type} #{@name}"
      label = " label: #{hook["label"]}" if hook["label"]
      logger.info  "Hook: Running #{id} hook#{label}".color(:cyan) if Ufo.config.hooks.show
      Runner.new(hook).run
    end

    def run?(hook)
      !!hook["execute"]
    end
  end
end
