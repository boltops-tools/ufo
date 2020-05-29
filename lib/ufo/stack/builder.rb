class Ufo::Stack
  class Builder
    class_attribute :context

    def initialize(context)
      @context = context
      # This builder class is really used as a singleton.
      # To avoid having to pass context to all the builder classes.
      self.class.context = @context
      @template = {
        Description: "Ufo ECS stack #{context.stack_name}",
      }
    end

    def build
      @template[:Parameters] = Parameters.new.build
      @template[:Conditions] = Conditions.new.build
      @template[:Resources] = Resources.new.build
      @template[:Outputs] = Outputs.new.build
      @template.deep_stringify_keys!
      @template = Ufo::Utils::Squeezer.new(@template).squeeze
      @template = CustomProperties.new(@template, @context.stack_name).apply
      YAML.dump(@template)
    end
  end
end
