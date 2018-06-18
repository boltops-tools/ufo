module Ufo
  class Stack
    include AwsService
    extend Memoist

    def initialize(options)
      @options = options
      @stack_name = @options[:stack_name] || raise("stack_name required")
    end

    # CloudFormation status codes, full list:
    #   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
    #
    #   CREATE_COMPLETE
    #   ROLLBACK_COMPLETE
    #   DELETE_COMPLETE
    #   UPDATE_COMPLETE
    #   UPDATE_ROLLBACK_COMPLETE
    #
    #   CREATE_FAILED
    #   DELETE_FAILED
    #   ROLLBACK_FAILED
    #   UPDATE_ROLLBACK_FAILED
    #
    #   CREATE_IN_PROGRESS
    #   DELETE_IN_PROGRESS
    #   REVIEW_IN_PROGRESS
    #   ROLLBACK_IN_PROGRESS
    #   UPDATE_COMPLETE_CLEANUP_IN_PROGRESS
    #   UPDATE_IN_PROGRESS
    #   UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS
    #   UPDATE_ROLLBACK_IN_PROGRESS
    #
    def launch
      stack = find_stack(@stack_name)
      exit_with_message(stack) if stack && !updatable?(stack)
      stack ? update_stack : create_stack

      # wait...
    end

    def find_stack(stack_name)
      resp = cloudformation.describe_stacks(stack_name: stack_name)
      stack = resp.stacks.first
    rescue Aws::CloudFormation::Errors::ValidationError => e
      # example: Stack with id hi-web does not exist
      if e.message =~ /Stack with/ && e.message =~ /does not exist/
        nil
      else
        raise
      end
    end

    def create_stack
      puts "Creating stack #{@stack_name}..."
      cloudformation.create_stack(stack_name: @stack_name, template_body: template_body)
      puts "Created stack."
    end

    def update_stack
      puts "Updating stack..."
      begin
        puts template_body
        cloudformation.update_stack(stack_name: @stack_name, template_body: template_body)
      rescue Aws::CloudFormation::Errors::ValidationError => e
        handle_update_stack_error(e)
      end
      puts "Updated stack."
    end

    # Stack:arn:aws:cloudformation:... is in ROLLBACK_COMPLETE state and can not be updated.
    def handle_update_stack_error(e)
      if e.message =~ /is in ROLLBACK_COMPLETE state and can not be updated/
        puts "The #{@stack_name} stack is in #{"ROLLBACK_COMPLETE".colorize(:red)} and cannot be updated. Deleted the stack and try again."
        # TODO: fix aws cloudformation console url
        url = "https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/"
        puts "Here's the CloudFormation console url: "
        exit 1
      else
        raise
      end
    end

    def template_body
      path = File.expand_path("../cfn/stack.yml", File.dirname(__FILE__))
      RenderMePretty.result(path, context: template_scope)
    end
    memoize :template_body

    def template_scope
      scope = Ufo::TemplateScope.new(Ufo::DSL::Helper.new, nil)
      # Add additional variable to scope for CloudFormation template.
      # Dirties the scope but needed here.
      scope.assign_instance_variables(
        options: @options,
        stack_name: @stack_name,
      )
      scope
    end
    memoize :template_scope

    def exit_with_message(stack)
      url = "http://example-url"
      puts "The stack state is in: #{stack.stack_status}."
      puts "Here's the CloudFormation url to check for more details #{url}"
      exit 1
    end

    def updatable?(stack)
      stack.stack_status =~ /_COMPLETE$/
    end
  end
end
