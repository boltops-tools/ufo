class Ufo::Apps
  class CfnMap
    extend Memoist
    include Ufo::Stack::Helper

    def initialize(options = {})
      @options = options
      @cluster = @options[:cluster] || default_cluster(options[:service])
      @map = {}
    end

    # Example:
    #   {"development-demo-web-Ecs-1L3WUTJFFM5JV"=>"demo-web"}
    def map
      return @map if @populated

      populate_map!
      @populated = true
      @map
    end

    def summaries
      filter = %w[
        UPDATE_COMPLETE
        CREATE_COMPLETE
        UPDATE_ROLLBACK_COMPLETE
        UPDATE_IN_PROGRESS
        UPDATE_COMPLETE_CLEANUP_IN_PROGRESS
        UPDATE_ROLLBACK_IN_PROGRESS
        UPDATE_ROLLBACK_FAILED
        UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS
        REVIEW_IN_PROGRESS
      ]

      summaries = []
      next_token = true
      while next_token
        resp = cloudformation.list_stacks(stack_status_filter: filter)
        summaries += resp.stack_summaries
        next_token = resp.next_token
      end

      # look for stacks that beling that ufo create
      summaries.select do |s|
        s.template_description =~ /Ufo ECS stack/
      end
    end
    memoize :summaries

    def populate_map!
      threads = []
      summaries.each do |summary|
        threads << Thread.new do
          resp = cloudformation.describe_stack_resources(stack_name: summary.stack_name)
          ecs_resource = resp.stack_resources.find do |resource|
            resource.logical_resource_id == "Ecs"
          end
          # Example: "PhysicalResourceId": "arn:aws:ecs:us-east-1:111111111111:service/dev-demo-web-Ecs-1HRL8Y9F4D1CR"
          ecs_service_name = ecs_resource.physical_resource_id.split('/').last
          @map[ecs_service_name] = stack_name_to_service_name(summary.stack_name)
        end
      end
      threads.map(&:join)
    end

    def stack_name_to_service_name(stack_name)
      stack_name.sub("#{@cluster}-",'')
    end
  end
end
