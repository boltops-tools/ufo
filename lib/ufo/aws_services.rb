require "aws-sdk-applicationautoscaling"
require "aws-sdk-cloudformation"
require "aws-sdk-cloudwatchlogs"
require "aws-sdk-ec2"
require "aws-sdk-ecr"
require "aws-sdk-ecs"
require "aws-sdk-elasticloadbalancingv2"
require "aws-sdk-ssm"

require "aws_mfa_secure/ext/aws" # add MFA support
require "cfn_status"

module Ufo
  module AwsServices
    extend Memoist

    def applicationautoscaling
      Aws::ApplicationAutoScaling::Client.new(aws_options)
    end
    memoize :applicationautoscaling

    def cloudformation
      Aws::CloudFormation::Client.new(aws_options)
    end
    memoize :cloudformation

    def cloudwatchlogs
      Aws::CloudWatchLogs::Client.new(aws_options)
    end
    memoize :cloudwatchlogs

    def ec2
      Aws::EC2::Client.new(aws_options)
    end
    memoize :ec2

    def ecr
      Aws::ECR::Client.new(aws_options)
    end
    memoize :ecr

    def ecs
      Aws::ECS::Client.new(aws_options)
    end
    memoize :ecs

    def elb
      Aws::ElasticLoadBalancingV2::Client.new(aws_options)
    end
    memoize :elb

    def ssm_client
      Aws::SSM::Client.new
    end
    memoize :ssm_client

    # Override the AWS retry settings with AWS clients.
    #
    # The aws-sdk-core has exponential backup with this formula:
    #
    #   2 ** c.retries * c.config.retry_base_delay
    #
    # Source:
    #   https://github.com/aws/aws-sdk-ruby/blob/version-3/gems/aws-sdk-core/lib/aws-sdk-core/plugins/retry_errors.rb
    #
    # So the max delay will be 2 ** 7 * 0.6 = 76.8s
    #
    # Only scoping this to deploy because dont want to affect people's application that use the aws sdk.
    #
    # There is also additional rate backoff logic elsewhere, since this is only scoped to deploys.
    #
    # Useful links:
    #   https://github.com/aws/aws-sdk-ruby/blob/master/gems/aws-sdk-core/lib/aws-sdk-core/plugins/retry_errors.rb
    #   https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html
    #
    def aws_options
      options = {
        retry_limit: 7, # default: 3
        retry_base_delay: 0.6, # default: 0.3
      }
      options.merge!(
        log_level: :debug,
        logger: Logger.new($stdout),
      ) if ENV['UFO_DEBUG_AWS_SDK']
      options
    end

    def find_stack(stack_name)
      resp = cloudformation.describe_stacks(stack_name: stack_name)
      resp.stacks.first
    rescue Aws::CloudFormation::Errors::ValidationError => e
      # example: Stack with id demo-web does not exist
      if e.message =~ /Stack with/ && e.message =~ /does not exist/
        nil
      else
        raise
      end
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
  end
end
