require "aws-logs"

class Ufo::CLI
  class Logs < Base
    delegate :service, to: :info

    def run
      log = find_log_group_name
      logger.info "Showing logs for stack: #{@stack_name} log group: #{log["awslogs-group"]} and stream prefix: #{log["awslogs-stream-prefix"]}"
      if log
        cloudwatch_tail(log)
      else
        logger.info "Unable to find log group for service: #{service.service_name}"
      end
    end

    def find_log_group_name
      unless info.service
        logger.info "Cannot find stack: #{@stack_name}"
        exit 1
      end
      task_definition = info.service.task_definition
      resp = ecs.describe_task_definition(task_definition: task_definition)

      container_definitions = resp.task_definition.container_definitions

      if container_definitions.size > 1 && !@options[:container]
        logger.info "Multiple containers found. ufo logs will use the first container."
        logger.info "You can also use the --container option to set the container to use."
      end

      definition = if @options[:container]
                     container_definitions.find do |c|
                       c.name == @options[:container]
                     end
                   else
                     container_definitions.first
                   end

      unless definition
        logger.error "ERROR: unable to find a container".color(:red)
        logger.error "You specified --container #{@options[:container]}" if @options[:container]
        exit
      end

      log_conf = definition.log_configuration
      unless log_conf
        logger.error "ERROR: Unable to find a log_configuration for container"
        logger.error "You specified --container #{@options[:container]}" if @options[:container]
        exit 1
      end

      if log_conf.log_driver == "awslogs"
        # options["awslogs-group"]
        # options["awslogs-region"]
        # options["awslogs-stream-prefix"]
        log_conf.options
      else
        logger.error "ERROR: Only supports awslogs driver. Detected log_driver: #{log_conf.log_driver}".color(:red)
        exit 1
      end
    end

    def cloudwatch_tail(log={})
      o = {
        log_group_name: log["awslogs-group"],
        log_stream_name_prefix: log["awslogs-stream-prefix"],
        since: @options[:since] || "10m", # by default, search only 10 mins in the past
        follow: @options[:follow],
        format: @options[:format],
      }
      o[:filter_pattern] = filter_pattern
      cw_tail = AwsLogs::Tail.new(o)
      cw_tail.run
    end

    def filter_pattern
      @options[:filter_pattern] ? @options[:filter_pattern] : Ufo.config.logs.filter_pattern
    end
  end
end
