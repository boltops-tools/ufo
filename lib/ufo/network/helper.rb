class Ufo::Network
  module Helper
    private
    # for balancer default profile
    def configure_network_settings
      network = Setting.new(@options[:vpc_id])
      @options = @options.dup
      @options[:vpc_id] = network.vpc_id
      @options[:subnets] = network.subnet_ids
    end
  end
end
