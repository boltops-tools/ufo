module Ufo
  # To include this module must have this in initialize:
  #
  # def initialize(optiions, ...)
  #   @options = options
  #   ...
  # end
  #
  # So @options must be set
  module Defaults
    # image: 123456789.dkr.ecr.us-east-1.amazonaws.com/sinatra
    # # service to cluster mapping, overrides default cluster cli overrides this
    # service_cluster:
    #   default: prod-lo
    #   hi-web-prod: prod-hi
    #   hi-clock-prod: prod-lo
    #   hi-worker-prod: prod-lo
    #
    # Assumes that @service is set in the class that the Defaults module is included in.
    def default_cluster
      service_cluster = settings.data["service_cluster"]
      service_cluster[@service] || service_cluster["default"]
    end

    # These default service values only are used when a service is created by `ufo`
    def default_maximum_percent
      Integer(new_service_settings["maximum_percent"] || 200)
    end

    def default_minimum_healthy_percent
      Integer(new_service_settings["minimum_healthy_percent"] || 100)
    end

    def default_desired_count
      Integer(new_service_settings["desired_count"] || 1)
    end

    def new_service_settings
      settings.data["new_service"] || {}
    end

    def settings
      @settings ||= Settings.new(@options[:project_root])
    end
  end
end
