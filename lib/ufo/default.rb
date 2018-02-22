module Ufo
  # To include this module must have this in initialize:
  #
  # def initialize(optiions, ...)
  #   @options = options
  #   ...
  # end
  #
  # So @options must be set
  module Default
    # The default cluster normally defaults to the Ufo.env value.
    # But it can be overriden by ufo/settings.yml cluster
    #
    # More info: http://ufoships.com/docs/settings/
    def default_cluster
      setting.data["cluster"] || Ufo.env
    end

    # These default service values only are used when a service is created by `ufo`
    def default_maximum_percent
      Integer(new_service_setting["maximum_percent"] || 200)
    end

    def default_minimum_healthy_percent
      Integer(new_service_setting["minimum_healthy_percent"] || 100)
    end

    def default_desired_count
      Integer(new_service_setting["desired_count"] || 1)
    end

    def new_service_setting
      setting.data["new_service"] || {}
    end

    def setting
      @setting ||= Setting.new
    end
  end
end
