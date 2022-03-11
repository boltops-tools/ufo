module Ufo::TaskDefinition::Helpers
  module AwsHelper
    extend Memoist
    extend ActiveSupport::Concern

    included do
      delegate :account, :region, to: :aws
      alias_method :aws_region, :region
      alias_method :current_region, :region
    end

    # Duplicated in vars.rb
    def aws
      AwsData.new
    end
    memoize :aws
  end
end
