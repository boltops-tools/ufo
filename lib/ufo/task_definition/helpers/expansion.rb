module Ufo::TaskDefinition::Helpers
  module Expansion
    include Ufo::Concerns::Names

    # Note: vars expansion is different than the TaskDefinition expansion helper
    # See: Ufo::TaskDefinition::Helpers::Vars#expansion
    def expansion(string)
      names.expansion(string) # dasherize: false. dont turn SECRET_NAME => SECRET-NAME
    end
  end
end
