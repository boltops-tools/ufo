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

      all_task_arns = task_arns.each_slice(100).map do |arns|
        resp = ecs.describe_tasks(tasks: arns, cluster: @cluster)
        resp["tasks"]
      end.flatten

      display_tasks(all_task_arns)
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
      puts error_event.message.color(:red)
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

      puts "There is an issue scaling the #{@service.color(:green)} service to #{service.desired_count}.  Here's the error:"
      puts error_event.message.color(:red)
      if service.launch_type == "EC2"
        puts "If AutoScaling is set up for the container instances, it can take a little time to add additional instances. You'll see this message until the capacity is added."
      end
    end

    def display_tasks(tasks)
      table = Text::Table.new
      Task.extra_columns = @options[:extra]
      table.head = Task.header
      tasks = tasks.sort_by { |t| t["task_arn"] }
      tasks.each do |t|
        task = Task.new(t)
        table.rows << task.to_a unless task.hide?
      end
      puts table
    end

    def statuses
      status = @options[:status].upcase
      valid_statuses = %w[RUNNING PENDING STOPPED]
      all_statuses = valid_statuses + ["ALL"]
      unless all_statuses.include?(status)
        puts "Invalid status filter provided. Please provided one of the following:"
        puts all_statuses.map(&:downcase).join(", ")
        exit 1
      end

      status == "ALL" ? valid_statuses : [status]
    end

    def task_arns
      threads, results = [], {}
      statuses.each do |status|
        threads << Thread.new do
          options = {
            service_name: service.service_name,
            cluster: @cluster,
            desired_status: status,
          }
          # Limit display of too many stopped tasks
          options[:max_results] = 20 if status == "STOPPED"
          resp = ecs.list_tasks(options)
          results[status] = resp.task_arns
        end
      end
      threads.map(&:join)
      results.values.flatten.uniq
    end
    memoize :task_arns
  end
end
