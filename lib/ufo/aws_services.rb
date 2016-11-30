require 'aws-sdk'

module Ufo
  module AwsServices
    def ecs
      @ecs ||= Aws::ECS::Client.new(region: region)
    end

    def elb
      @elb ||= Aws::ElasticLoadBalancingV2::Client.new(region: region)
    end

    def ecr
      @ecr ||= Aws::ECR::Client.new(region: region)
    end

    def region
      ENV['REGION'] || 'us-east-1'
    end
  end
end
