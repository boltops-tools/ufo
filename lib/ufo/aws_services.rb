require "aws-sdk-ecs"
require "aws-sdk-ec2"
require "aws-sdk-elasticloadbalancingv2"
require "aws-sdk-cloudwatchlogs"

module Ufo
  module AwsServices
    def ecs
      @ecs ||= Aws::ECS::Client.new
    end

    def elb
      @elb ||= Aws::ElasticLoadBalancingV2::Client.new
    end

    def ecr
      @ecr ||= Aws::ECR::Client.new
    end

    def cloudwatchlogs
      @cloudwatchlogs ||= Aws::CloudWatchLogs::Client.new
    end
  end
end
