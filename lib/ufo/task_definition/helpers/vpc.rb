module Ufo::TaskDefinition::Helpers
  module Vpc
    extend Memoist
    include Ufo::AwsServices

    def default_vpc
      resp = ec2.describe_vpcs(filters: [name: "isDefault", values: ["true"]])
      vpc = resp.vpcs.first
      if vpc
        vpc.vpc_id
      else
        logger.error "No default vpc found".color(:red)
        logger.error <<~EOL
          Please configure the `config.vpc` settings.

          Docs: https://ufoships.com/config/vpc/

        EOL
        exit 1
      end
    end
    memoize :default_vpc

    def subnets_for(vpc_id)
      resp = ec2.describe_subnets(filters: [name: "vpc-id", values: [vpc_id]])
      subnets = resp.subnets
      subnets.map(&:subnet_id)
    end

    def default_subnets
      if default_vpc.nil?
        logger.error "ERROR: no default subnets because no default vpc found".color(:red)
        exit 1
      end
      resp = ec2.describe_subnets(filters: [name: "vpc-id", values: [default_vpc]])
      subnets = resp.subnets
      subnets.map(&:subnet_id)
    end
    memoize :default_subnets

    def key_pairs(regexp=nil)
      resp = ec2.describe_key_pairs
      key_names = resp.key_pairs.map(&:key_name)
      key_names.select! { |k| k =~ regexp } if regexp
      key_names
    end
  end
end
