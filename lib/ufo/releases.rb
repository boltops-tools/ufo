require 'text-table'

module Ufo
  class Releases < Base
    def list
      puts "Recent task definitions for this service:"
      arns = task_definition_arns(@service)
      task_definitions = arns.map { |arn| arn.split('/').last }
      task_definitions.each do |name|
        puts "  #{name}"
      end
    end
  end
end
