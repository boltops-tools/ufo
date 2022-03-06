class Ufo::CLI
  class Scale < Base
    delegate :service, :service?, :stack_resources, to: :info

    def initialize(options={})
      super
      @desired = options[:desired]
      @min = options[:min]
      @max = options[:max]
    end

    def update
      unless service?
        logger.error "ERROR: Unable to find the #{service}.".color(:red)
        logger.error "Are you sure you are trying to scale the right app?"
        exit 1
      end

      unless @desired || @min || @max
        logger.info <<~EOL
          No --desired --min or --max options provided
          Not taking any actions
        EOL
        return
      end

      logger.info "Configuring scaling settings for #{@stack_name}"
      set_desired_count
      set_autoscaling
      warning
    end

    def set_desired_count
      return unless @desired
      ecs.update_service(
        service: service.service_name,
        cluster: @cluster,
        desired_count: @desired
      )
      logger.info "Configured desired count to #{@desired}"
    end

    def set_autoscaling
      return unless @min || @max
      scalable_target = stack_resources.find do |r|
        r.logical_resource_id == "ScalingTarget"
      end
      register_scalable_target(scalable_target)
      logger.info "Configured autoscaling to min: #{@min} max: #{@max}"
    end

    def register_scalable_target(scalable_target)
      # service/dev/app1-web-dev-EcsService-Q0XkN6VtxGWv|ecs:service:DesiredCount|ecs
      resource_id, scalable_dimension, service_namespace = scalable_target.physical_resource_id.split('|')
      applicationautoscaling.register_scalable_target(
        max_capacity: @max,
        min_capacity: @min,
        resource_id: resource_id,
        scalable_dimension: scalable_dimension,
        service_namespace: service_namespace,
      )
    rescue Aws::ApplicationAutoScaling::Errors::ValidationException => e
      logger.error "ERROR: #{e.class} #{e.message}".color(:red)
      exit 1
    end

    def warning
      return unless Ufo.config.scale.warning
      logger.info <<~EOL
        Note: The settings are temporary.
        They can be overwritten in the next `ufo ship` deploy.
        To make the settings permanent update your ufo config.

        See: https://ufoships.com/docs/config/

        You can also turn off this warning with

            config.scale.warning = false

      EOL
    end
  end
end
