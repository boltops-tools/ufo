module Ufo::TaskDefinition::Helpers
  module Ssm
    def ssm(name, options={})
      fetcher = Ssm::Fetcher.new(options)
      fetcher.fetch(name)
    end
  end
end
