# Creating this class pass so we can have a reference to their properties in
# memory: cluster_name and service_name.
# This helps us avoid making additional API calls to describe and lookup the information.
#
# Also this class allows us to pass one object around instead of both
# cluster_name and service_name.
#
# This is really only used in the Ufo::Ship class.
module Ufo
  module ECS
    Service = Struct.new(:cluster_arn, :service_arn) do
      def cluster_name
        cluster_arn.split('/').last
      end

      def service_name
        service_arn.split('/').last
      end
    end
  end
end
