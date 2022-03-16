require "cfn_status"

module Ufo::AwsServices
  module Concerns
    extend Memoist

    def find_stack(stack_name)
      resp = cfn.describe_stacks(stack_name: stack_name)
      resp.stacks.first
    rescue Aws::CloudFormation::Errors::ValidationError => e
      # example: Stack with id demo-web does not exist
      if e.message =~ /Stack with/ && e.message =~ /does not exist/
        nil
      else
        raise
      end
    end

    def stack_resources(stack_name)
      resp = cfn.describe_stack_resources(stack_name: stack_name)
      resp.stack_resources
    rescue Aws::CloudFormation::Errors::ValidationError => e
      e.message.include?("does not exist") ? return : raise
    end

    def task_definition_arns(family, max_items=10)
      resp = ecs.list_task_definitions(
        family_prefix: family,
        sort: "DESC",
      )
      arns = resp.task_definition_arns
      arns = arns.select do |arn|
        task_definition = arn.split('/').last.split(':').first
        task_definition == family
      end
      arns[0..max_items]
    end

    def status
      CfnStatus.new(@stack_name) # NOTE: @stack_name must be set in the including Class
    end
    memoize :status

    def find_stack_resources(stack_name)
      resp = cfn.describe_stack_resources(stack_name: stack_name)
      resp.stack_resources
    rescue Aws::CloudFormation::Errors::ValidationError => e
      if e.message.include?("does not exist")
        nil
      else
        raise
      end
    end
  end
end
