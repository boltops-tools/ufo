require "aws-sdk-acm"
require "aws-sdk-applicationautoscaling"
require "aws-sdk-cloudformation"
require "aws-sdk-cloudwatchlogs"
require "aws-sdk-ec2"
require "aws-sdk-ecr"
require "aws-sdk-ecs"
require "aws-sdk-elasticloadbalancingv2"
require "aws-sdk-s3"
require "aws-sdk-ssm"
require "aws-sdk-wafv2"

require "aws_mfa_secure/ext/aws" # add MFA support

module Ufo
  module AwsServices
    extend Memoist
    include Concerns

    def acm
      Aws::ACM::Client.new(aws_options)
    end
    memoize :acm

    def applicationautoscaling
      Aws::ApplicationAutoScaling::Client.new(aws_options)
    end
    memoize :applicationautoscaling

    def cfn
      Aws::CloudFormation::Client.new(aws_options)
    end
    memoize :cfn

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

    def s3
      Aws::S3::Client.new(aws_options)
    end
    memoize :s3

    # ssm is a helper method
    def ssm_client
      Aws::SSM::Client.new(aws_options)
    end
    memoize :ssm_client

    # waf is a helper method
    def waf_client
      Aws::WAFV2::Client.new(aws_options)
    end
    memoize :waf_client

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
  end
end
