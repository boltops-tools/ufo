# Provides access to default network settings for a vpc: subnets and security_group
# If no @vpc_id is provided to the initializer then the default vpc is used.
class Ufo::Network
  class Fetch
    include Ufo::AwsService
    extend Memoist

    def initialize(vpc_id)
      @vpc_id = vpc_id
    end

    def vpc_id
      return @vpc_id if @vpc_id

      resp = ec2.describe_vpcs(filters: [
        {name: "isDefault", values: ["true"]}
      ])
      default_vpc = resp.vpcs.first
      if default_vpc
        default_vpc.vpc_id
      else
        puts "A default vpc was not found in this AWS account and region.".colorize(:red)
        puts "Because there is no default vpc, please specify the --vpc-id option.  More info: http://ufoships.com/reference/ufo-init/"
        exit 1
      end
    end
    memoize :vpc_id

    # all subnets
    def subnet_ids
      resp = ec2.describe_subnets(filters: [
        {name: "vpc-id", values: [vpc_id]}
      ])
      resp.subnets.map(&:subnet_id).sort
    end
    memoize :subnet_ids

    # default security group
    def security_group_id
      resp = ec2.describe_security_groups(filters: [
        {name: "vpc-id", values: [vpc_id]},
        {name: "group-name", values: ["default"]}
      ])
      resp.security_groups.first.group_id
    end
    memoize :security_group_id
  end
end
