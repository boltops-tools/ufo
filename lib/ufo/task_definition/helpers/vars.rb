module Ufo::TaskDefinition::Helpers
  module Vars
    def env(text)
      Builder.new(text: text).env
    end
    alias_method :env_vars, :env
    alias_method :environment, :env

    def env_file(path=nil)
      Builder.new(file: path).env
    end

    def secrets(text)
      Builder.new(text: text).secrets
    end

    def secrets_file(path=nil)
      Builder.new(file: path).secrets
    end
  end
end
