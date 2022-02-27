require 'text-table'
require 'tty-screen'

class Ufo::CLI
  class Ps < Base
    include Ufo::AwsServices
    include Ufo::Concerns::Autoscaling
    delegate :service, to: :info

    def run
      unless service
        logger.info info.no_service_message
        return
      end

      summary

      if task_arns.empty?
        logger.info "There are 0 running tasks."
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
      return unless Ufo.config.ps.summary

      logger.info "Stack: #{@stack_name}"
      logger.info "Service: #{service.service_name}"
      logger.info "Status: #{service.status}" unless service.status == "ACTIVE" # not very useful when ACTIVE
      logger.info "Tasks: #{tasks_counts}"
      logger.info "Launch type: #{service.launch_type}" if service.launch_type
      elb = info.load_balancer(service)
      logger.info "#{elb.type.capitalize} ELB: #{elb.dns_name}" if elb
      logger.info "Url: #{info.url}" if info.url
    end

    def tasks_counts
      message = "Running: #{service.running_count} Desired: #{service.desired_count}"
      if scalable_target
        message += " Min: #{scalable_target.min_capacity} Max: #{scalable_target.max_capacity}"
      end
      message
    end

    def scalable_target
      return unless autoscaling_enabled?
      # Docs: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ApplicationAutoScaling/Client.html#describe_scalable_targets-instance_method
      # ECS service - The resource type is service and the unique identifier is the cluster name and service name. Example: service/default/sample-webapp.
      resource_id = "service/#{@cluster}/#{service.service_name}"
      resp = applicationautoscaling.describe_scalable_targets(
        service_namespace: "ecs",
        resource_ids: [resource_id],
      )
      resp.scalable_targets.first # scalable_target
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

      logger.error "There are targets in the target group reporting unhealthy.  This can cause containers to cycle. Here's the error:"
      logger.error error_event.message.color(:red)
      logger.error <<~EOL
        Check out the ECS console and EC2 Load Balancer console for more info.
        Sometimes they may not helpful :(
        Docs that may help: https://ufoships.com/docs/debug/unhealthy-targets/
      EOL
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

      logger.info "There is an issue scaling the #{@service.color(:green)} service to #{service.desired_count}.  Here's the error:"
      logger.info error_event.message.color(:red)
      if service.launch_type == "EC2"
        logger.info "If AutoScaling is set up for the container instances, it can take a little time to add additional instances. You'll see this message until the capacity is added."
      end
    end

    def display_tasks(raw_tasks)
      raw_tasks.sort_by! { |t| t["task_arn"] }
      tasks = raw_tasks.map { |t| Task.new(t) } # will have Task objects after this point
      tasks = tasks.reject(&:hide?)
      show_notes = show_notes(tasks)

      format = determine_format(tasks)
      o = @options.dup # Cant modify frozen Thor options
      o[:format] ||= format

      presenter = CliFormat::Presenter.new(o)
      header = show_notes ? Task.header : Task.header[0..-2]
      presenter.header = header
      tasks.each do |task|
        row = show_notes ? task.to_a : task.to_a[0..-2]
        presenter.rows << row
      end
      presenter.show
    end

    def show_notes(tasks)
      tasks.detect { |t| !t.notes.blank? }
    end

    # auto format will display in json if the output is to wide
    # otherwise it defaults to table
    def determine_format(tasks)
      if Ufo.config.ps.format == "auto"
        max = max_table_width(tasks)
        max >= TTY::Screen.width ? "json" : "table"
      else
        Ufo.config.ps.format
      end
    end

    def max_table_width(tasks)
      max = 0
      tasks.each do |row|
        columns = row.to_a
        width = columns.inject(0) do |total, column|
          total += column.to_s.length
        end
        max = width if width >= max
      end
      padding = Task.header.size * 3 + 4
      # max full column width. accounts for all the rows plus the padding from the table output
      max + padding
    end

    def statuses
      status = @options[:status] || "ALL" # can be nil when used from ship
      status = status.upcase
      valid_statuses = %w[RUNNING PENDING STOPPED]
      all_statuses = valid_statuses + ["ALL"]
      unless all_statuses.include?(status)
        logger.error "Invalid status filter provided. Please provided one of the following:"
        logger.error all_statuses.map(&:downcase).join(", ")
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
