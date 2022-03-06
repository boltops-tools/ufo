class Ufo::CLI::Ps
  class Errors < Ufo::CLI::Ps
    extend Memoist

    def initialize(options={})
      super
      @tasks = options[:tasks]
    end

    def show
      message = recent_message
      return unless message
      return if message =~ /has reached a steady state/

      scale
      target_group
      deployment_configuration
      catchall
    end

    # If running count < desired account for a long time
    # And see was unable to place a task
    # Probably not enough capacity
    def scale
      return if service.running_count >= service.desired_count

      error_event = recent_events.find do |e|
        e.message =~ /was unable to place a task/
      end
      return unless error_event

      logger.info "There is an issue scaling the #{@stack_name.color(:green)} service to #{service.desired_count}.  Here's the error:"
      logger.info error_event.message.color(:red)
      if service.launch_type == "EC2"
        logger.info <<~EOL
          If AutoScaling is set up for the container instances,
          it can take a little time to add additional instances.
          You'll see this message until the capacity is added.
        EOL
      end
    end

    # The error currently happens to be the 5th element.
    #
    # Example:
    #     (service XXX) (instance i-XXX) (port 32875) is unhealthy in (target-group arn:aws:elasticloadbalancing:us-east-1:111111111111:targetgroup/devel-Targe-1111111111111/1111111111111111) due to (reason Health checks failed with these codes: [400])">]
    def target_group
      error_event = recent_events.find do |e|
        e.message =~ /is unhealthy in/ &&
        e.message =~ /targetgroup/
      end
      return unless error_event

      logger.error "There are targets in the target group reporting unhealthy.  This can cause containers to cycle. Here's the error:"
      logger.error error_event.message.color(:red)
      logger.error <<~EOL
        Check out the ECS console and EC2 Load Balancer console for more info.
        Sometimes they may not helpful :(
        Docs that may help: https://ufoships.com/docs/debug/unhealthy-targets/
      EOL
    end

    # To reproduce
    #
    # .ufo/config.rb
    #
    #     Ufo.configure do |config|
    #       config.ecs.maximum_percent = 150 # need at least 200 to go from 1 to 2 containers
    #       config.ecs.minimum_healthy_percent = 100
    #     end
    #
    # Event message error:
    #
    #     ERROR: (service app1-web-dev-EcsService-8FMliG8m6M2p) was unable to stop or start tasks during a deployment because of the service deployment configuration. Update the minimumHealthyPercent or maximumPercent value and try again.
    #
    def deployment_configuration
      message = recent_message
      return unless message.include?("unable") && message.include?("deployment configuration")

      logger.error "ERROR: Deployment Configuration".color(:red)
      logger.error <<~EOL
        You might have a Deployment Configuration that prevents the deployment from completing.

        See: https://ufoships.com/docs/debug/deployment-configuration/

      EOL
    end

    # Example:
    #     (service app1-web-dev-EcsService-8FMliG8m6M2p) was unable to stop or start tasks during a deployment because of the service deployment configuration. Update the minimumHealthyPercent or maximumPercent value and try again.
    def catchall
      words = %w[fail unable error]
      recent_messages = recent_events.map(&:message)
      message = recent_messages.find  do |message|
        words.detect { |word| message.include?(word) }
      end

      return unless message
      logger.error "ERROR: #{message}".color(:red)

      logger.error <<~EOL
        You might have to #{cancel_actions[:cfn]} the stack with:

            ufo #{cancel_actions[:ufo]}

        And try again after fixing the issue.
      EOL
    end

  private
    def cancel_actions
      stack = find_stack(@stack_name)
      if stack && stack.stack_status == "CREATE_COMPLETE"
        { cfn: "delete", ufo: "destroy" }
      else
        { cfn: "cancel", ufo: "cancel" }
      end
    end
    memoize :cancel_actions

    # only check a few most recent
    def recent_events
      service["events"][0..4]
    end

    def recent_message
      recent = recent_events.first
      return unless recent
      recent.message ? recent.message : nil
    end
  end
end
