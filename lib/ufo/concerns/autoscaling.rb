module Ufo::Concerns
  module Autoscaling
    def autoscaling_enabled?
      autoscaling.enabled && autoscaling.min_capacity && autoscaling.max_capacity
    end

    def autoscaling
      Ufo.config.autoscaling
    end
  end
end
