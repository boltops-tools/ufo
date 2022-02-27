Ufo.configure do |config|
  config.autoscaling.enabled = true
  config.autoscaling.min_capacity = 1
  config.autoscaling.max_capacity = 1
  config.autoscaling.target_value = 50.0
end
