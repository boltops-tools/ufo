require 'text-table'

module Ufo
  class Releases < Base
    def list
      resp = ecs.list_task_definitions(
        family_prefix: @service,
        sort: "DESC",
      )
      max_items = 10
      arns = resp.task_definition_arns[0..max_items]
      task_definitions = arns.map { |arn| arn.split('/').last }

      puts "Recent task definitions for this service:"
      task_definitions.each do |name|
        puts "  #{name}"
      end
    end
  end
end
