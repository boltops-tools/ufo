class Ufo::Stack::Builder
  class Base
    include Ufo::Settings

    def initialize
      copy_instance_variables
    end

    # Copy the instance variables from TemplateScope Stack Builder classes
    def copy_instance_variables
      context = Ufo::Stack::Builder.context
      scope = context.scope
      scope.instance_variables.each do |var|
        val = scope.instance_variable_get(var)
        instance_variable_set(var, val)
      end
    end

    def self.build
      new.build
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
      settings_key = "#{type}_security_groups".to_sym
      group_ids = Ufo::Setting::SecurityGroups.new(@service, settings_key).load
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
      managed = settings[:managed_security_groups]
      managed.nil? ? true : managed
    end
  end
end
