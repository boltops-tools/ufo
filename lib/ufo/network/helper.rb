class Ufo::Network
  module Helper
    private
    # for balancer default profile
    def configure_network_settings
      fetch = Fetch.new(@options[:vpc_id])
      @options = @options.dup
      @options[:vpc_id] ||= fetch.vpc_id
      @options[:ecs_subnets] ||= fetch.subnet_ids
      @options[:elb_subnets] ||= fetch.subnet_ids
    end
  end
end
