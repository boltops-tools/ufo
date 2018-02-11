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
    # The default cluster normally defaults to the UFO_ENV value.
    # But it can be overriden by ufo/settings.yml ufo_env_cluster_map
    #
    # More info: http://ufoships.com/docs/settings/
    def default_cluster
      #

      map = setting.data["ufo_env_cluster_map"]
      if map
        ecs_cluster = map[UFO_ENV] || map["default"]
      end

      ecs_cluster || UFO_ENV
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
      @setting ||= Setting.new(@options[:project_root])
    end
  end
end
