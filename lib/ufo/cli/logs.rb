require "aws-logs"

class Ufo::CLI
  class Logs < Base
    delegate :service, to: :info

    def run
      log = find_log_group_name
      puts "Showing logs for stack: #{@stack_name} log group: #{log["awslogs-group"]} and stream prefix: #{log["awslogs-stream-prefix"]}"
      if log
        cloudwatch_tail(log)
      else
        puts "Unable to find log group for service: #{service.service_name}"
      end
    end

    def find_log_group_name
      unless info.service
        logger.info "Cannot find ECS service for #{@stack_name}"
        exit 1
      end
      task_definition = info.service.task_definition
      resp = ecs.describe_task_definition(task_definition: task_definition)

      container_definitions = resp.task_definition.container_definitions

      unless container_definitions.size == 1
        puts "ERROR: ufo logs command only supports 1 container definition in the ECS task definition".color(:red)
        return
      end

      definition = container_definitions.first
      log_conf = definition.log_configuration

      if log_conf && log_conf.log_driver == "awslogs"
        # options["awslogs-group"]
        # options["awslogs-region"]
        # options["awslogs-stream-prefix"]
        log_conf.options
      else
        puts "Only supports awslogs driver. Detected log_driver: #{log_conf.log_driver}"
        return
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
