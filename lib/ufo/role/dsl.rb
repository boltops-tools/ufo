module Ufo::Role
  class DSL
    def initialize(path)
      @path = path # IE: .ufo/iam_roles/task_role.rb
    end

    def evaluate
      instance_eval(IO.read(@path), @path)
    end

    def iam_policy(policy_name, statements)
      role_type = File.basename(@path).sub('.rb','') # task_role or execution_role
      Registry.register_policy(role_type, policy_name, statements)
    end

    def managed_iam_policy(*policies)
      role_type = File.basename(@path).sub('.rb','') # task_role or execution_role
      Registry.register_managed_policy(role_type, policies)
    end
  end
end
