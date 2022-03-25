require "set"

module Ufo::IamRole
  class Registry
    class_attribute :policies
    self.policies = {}
    class_attribute :managed_policies
    self.managed_policies = {}

    class << self
      def register_policy(role_type, policy_name, *statements)
        statements.flatten!
        self.policies[role_type] ||= Set.new
        self.policies[role_type].add([policy_name, statements]) # using set so Dsl can safely be evaluated multiple times
      end

      def register_managed_policy(role_type, *policies)
        policies.flatten!
        self.managed_policies[role_type] ||= Set.new
        self.managed_policies[role_type].merge(policies) # using set so Dsl can safely be evaluated multiple times
      end
    end
  end
end
