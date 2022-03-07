class Ufo::Cfn::Stack
  class Builder < Ufo::Cfn::Base
    include Ufo::Utils::Logging

    def initialize(options={})
      super
      @vars = options[:vars]
      @template = {Description: "UFO ECS stack #{@vars[:stack_name]}"}
    end

    def build
      @template[:Parameters] = Parameters.build(@options)
      @template[:Conditions] = Conditions.build(@options)
      @template[:Resources] = Resources.build(@options)
      @template[:Outputs] = Outputs.build(@options)
      @template.deep_stringify_keys!
      @template = Ufo::Utils::Squeezer.new(@template).squeeze
      @template = CustomProperties.new(@template, @vars[:stack_name]).apply
      write(@template)
    end

    def write(template)
      text = YAML.dump(template)
      path = ".ufo/output/template.yml"
      IO.write("#{Ufo.root}/#{path}", text)
      logger.info "Template built:        #{path}"
      # Only basic YAML validation. Doesnt check for everything CloudFormation checks.
      # For CloudFormation checks handled with an exception handler in Cfn::Stack#print_code(exception)
      Ufo::Yaml.validate!(path)
      text
    end
  end
end
