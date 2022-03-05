require 'text-table'

class Ufo::CLI
  class Releases < Base
    def list
      logger.info "Latest task definitions for stack: #{@stack_name}"
      arns = task_definition_arns(@task_definition.name)
      task_definitions = arns.map { |arn| arn.split('/').last }
      task_definitions.each do |name|
        logger.info "    #{name}"
      end
    end
  end
end
