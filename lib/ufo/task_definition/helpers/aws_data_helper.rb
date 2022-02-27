module Ufo::TaskDefinition::Helpers
  module AwsDataHelper
    extend Memoist
    extend ActiveSupport::Concern

    included do
      delegate :account, :region, to: :aws_data
      alias_method :aws_region, :region
      alias_method :current_region, :region
    end

    # Duplicated in vars.rb
    def aws_data
      AwsData.new
    end
    memoize :aws_data
  end
end
