module Ufo::TaskDefinition::Helpers
  module StackOutput
    include Ufo::AwsServices
    include Ufo::Concerns::Names

    def stack_output(name)
      stack_name, output_key = name.split(".")
      stack_name = names.expansion(stack_name)
      resp = cloudformation.describe_stacks(stack_name: stack_name)
      stack = resp.stacks.first
      if stack
        o = stack.outputs.detect { |h| h.output_key == output_key }
      end

      if o
        o.output_value
      else
        logger.info "WARN: NOT FOUND: output #{key} for stack #{stack_name}"
        nil
      end
    end
  end
end
