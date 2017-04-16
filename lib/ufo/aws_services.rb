require 'aws-sdk'

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
  end
end
