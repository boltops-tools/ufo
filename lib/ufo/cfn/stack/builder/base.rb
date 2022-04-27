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
      return if type == :ecs && !manage_ecs_security_group? && group_ids.blank?

      groups = []
      groups += group_ids
      groups += [managed_security_group(type)] if manage_ecs_security_group? || type == :elb
      groups
    end

    def managed_security_group(type)
      logical_id = type == :elb || manage_ecs_security_group? ? "#{type.to_s.camelize}SecurityGroup" : "AWS::NoValue"
      {Ref: logical_id}
    end

    # With network mode is awsvpc always create UFO managed ECS security group
    # With bridge mode, never create as there's no point.
    def manage_ecs_security_group?
      vars[:container][:network_mode].to_s == 'awsvpc'
    end

    def self.build(options={})
      new(options).build
    end
  end
end
