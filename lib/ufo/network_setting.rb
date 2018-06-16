module Ufo
  module NetworkSetting
  private
    # for balancer default profile
    def configure_network_settings
      network = ::Balancer::Network.new(@options[:vpc_id])
      @options = @options.dup
      @options[:vpc_id] = network.vpc_id
      @options[:subnets] = network.subnet_ids
      @options[:security_groups] = [network.security_group_id] # used in balancer profile and params.yml for fargate
      if @options[:fargate_security_groups] && !@options[:fargate_security_groups].empty?
        @fargate_security_groups = @options[:fargate_security_groups]
      else
        @fargate_security_groups = ["auto"]
      end
    end
  end
end
