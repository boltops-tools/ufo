require 'text-table'

module Ufo
  class Ps < Base
    autoload :Task, 'ufo/ps/task'

    delegate :service, to: :info

    def run
      unless service
        puts no_service_message
        return
      end

      summary
      if task_arns.empty?
        puts "There are 0 running tasks."
        return
      end

      resp = ecs.describe_tasks(tasks: task_arns, cluster: @cluster)
      display_info(resp)

      display_scale_help
      display_target_group_help
    end

    def summary
      return unless @options[:summary]
      puts "=> Service: #{@pretty_service_name}"
      puts "   Service name: #{service.service_name}"
      puts "   Status: #{service.status}"
      puts "   Running count: #{service.running_count}"
      puts "   Desired count: #{service.desired_count}"
      puts "   Launch type: #{service.launch_type}"
      puts "   Task definition: #{service.task_definition.split('/').last}"
      elb = info.load_balancer(service)
      if elb
        puts "   Elb: #{elb.dns_name}"
        puts "   Elb type: #{elb.type}"
      end
      puts "   Route53: #{info.route53_dns}" if info.route53_dns
    end

    def display_target_group_help
      events = service["events"][0..4]
      return if events[0].message =~ /has reached a steady state/

      # The error currently happens to be the 5th element.
      #
      # Example:
      #  "(service XXX) (instance i-XXX) (port 32875) is unhealthy in (target-group arn:aws:elasticloadbalancing:us-east-1:111111111111:targetgroup/devel-Targe-1111111111111/1111111111111111) due to (reason Health checks failed with these codes: [400])">]
      error_event = events.find do |e|
        e.message =~ /is unhealthy in/ &&
        e.message =~ /targetgroup/
      end
      return unless error_event

      puts "There are targets in the target group reporting unhealthy.  This can cause containers to cycle. Here's the error:"
      puts error_event.message.colorize(:red)
      puts "Check out the ECS console events tab for more info."
    end

    # If the running count less than the desired account yet, check the events
    # and show a message with helpful debugging information.
    def display_scale_help
      return if service.running_count >= service.desired_count

      events = service["events"][0..3] # only check most recent 4 messages
      error_event = events.find do |e|
        e.message =~ /was unable to place a task/
      end
      return unless error_event

      puts "There is an issue scaling the #{@service.colorize(:green)} service to #{service.desired_count}.  Here's the error:"
      puts error_event.message.colorize(:red)
    end

    def display_info(resp)
      table = Text::Table.new
      table.head = Task.header
      resp["tasks"].each do |t|
        task = Task.new(t)
        table.rows << task.to_a unless task.hide?
      end
      puts table
    end

    def task_arns
      threads, results = [], {}
      statuses = %w[RUNNING PENDING STOPPED]
      statuses.each do |status|
        threads << Thread.new do
          resp = ecs.list_tasks(service_name: service.service_name, cluster: @cluster, desired_status: status)
          results[status] = resp.task_arns
        end
      end
      threads.map(&:join)
      results.values.flatten.uniq
    end
  end
end
