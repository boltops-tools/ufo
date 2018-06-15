module Ufo
  class Balancer::Init < Thor::Group
    include Thor::Actions
    include AwsService

    add_runtime_options! # force, pretend, quiet, skip options
      # https://github.com/erikhuda/thor/blob/master/lib/thor/actions.rb#L49

    # Interesting, when defining the options in this class it screws up the ufo balance -h menu
    Ufo::Balancer.cli_options.each do |o|
      class_option *o
    end
    def self.source_paths
      [File.expand_path("../../../template/.ufo/.balancer", __FILE__)]
    end

    def handle_default_option
      return unless @options[:default_vpc]

      resp = ec2.describe_vpcs(filters: [
        {name: "isDefault", values: ["true"]}
      ])
      default_vpc = resp.vpcs.first.vpc_id
      resp = ec2.describe_subnets(filters: [
        {name: "vpc-id", values: [default_vpc]}
      ])
      default_subnets = resp.subnets.map(&:subnet_id).sort

      @options = @options.dup
      @options[:vpc_id] = default_vpc
      @options[:subnets] = default_subnets
    end

    def starter_files
      directory ".", ".ufo/.balancer"
    end
  end
end
