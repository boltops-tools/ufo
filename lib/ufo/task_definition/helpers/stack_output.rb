module Ufo::TaskDefinition::Helpers
  module StackOutput
    include Ufo::AwsServices
    include Ufo::Concerns::Names

    def stack_output(name)
      stack_name, output_key = name.split(".")
      stack_name = names.expansion(stack_name)
      stack = find_stack(stack_name)
      unless stack
        logger.error "ERROR: Stack not found: #{stack_name}".color(:red)
        call_line = ufo_config_call_line
        DslEvaluator.print_code(call_line)
        return
      end

      o = stack.outputs.detect { |h| h.output_key == output_key }
      if o
        o.output_value
      else
        logger.warn "WARN: NOT FOUND: output #{output_key} for stack #{stack_name}".color(:yellow)
        nil
      end
    end
  end
end
