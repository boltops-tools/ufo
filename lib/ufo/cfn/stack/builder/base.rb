class Ufo::Cfn::Stack::Builder
  class Base < Ufo::Cfn::Base
    attr_reader :vars
    def initialize(options={})
      super
      @vars = options[:vars]
    end

    # type: elb or ecs
    # NOTE: Application ELBs always seem to need a security group even though the docs say its not required
    # However, there's a case where no ELB is created for a worker tier and if the settings are all blank
    # CloudFormation fails to resolve and splits out this error:
    #
    #     Template error: every Fn::Split object requires two parameters
    #
    # So we will not assign security groups at all for case of workers with no security groups at all.
    #
    def security_groups(type)
      group_ids = Ufo.config.vpc.security_groups[type] || []
      # no security groups at all
      return if !managed_security_groups? && group_ids.blank?

      groups = []
      groups += group_ids
      groups += [managed_security_group(type.to_s.camelize)] if managed_security_groups?
      groups
    end

    def managed_security_group(type)
      logical_id = managed_security_groups? ? "#{type.camelize}SecurityGroup" : "AWS::NoValue"
      {Ref: logical_id}
    end

    def managed_security_groups?
      managed = Ufo.config.vpc.security_groups.managed
      managed.nil? ? true : managed
    end

    def self.build(options={})
      new(options).build
    end
  end
end
