class Ufo::Network
  module Helper
    private
    # for balancer default profile
    def configure_network_settings
      @options = @options.dup
      return test_network_settings if ENV['TEST']

      fetch = Fetch.new(@options[:vpc_id])
      @options[:vpc_id] ||= fetch.vpc_id
      @options[:ecs_subnets] ||= fetch.subnet_ids
      @options[:elb_subnets] ||= fetch.subnet_ids
    end

    # hack for specs
    def test_network_settings
      @options[:vpc_id] = "vpc-111"
      @options[:ecs_subnets] = ["subnet-111", "subnet-222"]
      @options[:elb_subnets] = ["subnet-111", "subnet-222"]
      @options
    end
  end
end
