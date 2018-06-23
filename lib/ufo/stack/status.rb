require 'time'

# CloudFormation status codes, full list:
#   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
#
#   CREATE_COMPLETE
#   ROLLBACK_COMPLETE
#   DELETE_COMPLETE
#   UPDATE_COMPLETE
#   UPDATE_ROLLBACK_COMPLETE
#
#   CREATE_FAILED
#   DELETE_FAILED
#   ROLLBACK_FAILED
#   UPDATE_ROLLBACK_FAILED
#
#   CREATE_IN_PROGRESS
#   DELETE_IN_PROGRESS
#   REVIEW_IN_PROGRESS
#   ROLLBACK_IN_PROGRESS
#   UPDATE_COMPLETE_CLEANUP_IN_PROGRESS
#   UPDATE_IN_PROGRESS
#   UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS
#   UPDATE_ROLLBACK_IN_PROGRESS
#
class Ufo::Stack
  class Status
    include Ufo::AwsService
    include Ufo::Util

    attr_reader :events
    def initialize(stack_name)
      @stack_name = stack_name
      reset
    end

    def reset
      @events = [] # constantly replaced with recent events
      @last_shown_event_id = nil
      @stack_deletion_completed = nil
    end

    # check for /(_COMPLETE|_FAILED)$/ status
    def wait
      start_time = Time.now

      refresh_events
      until completed || @stack_deletion_completed
        show_events
      end
      show_events(true) # show the final event

      if @stack_deletion_completed
        puts "Stack #{@stack_name} deleted."
        return
      end

      if last_event_status =~ /_FAILED/
        puts "Stack failed: #{last_event_status}".colorize(:red)
        puts "Stack reason #{@events[0]["resource_status_reason"]}".colorize(:red)
      elsif last_event_status =~ /_ROLLBACK_/
        puts "Stack rolled back: #{last_event_status}".colorize(:red)
      else # success
        puts "Stack success status: #{last_event_status}".colorize(:green)
      end

      took = Time.now - start_time
      puts "Took for stack deployment: #{pretty_time(took).green}."
    end

    def completed
      last_event_status =~ /(_COMPLETE|_FAILED)$/ &&
      @events[0]["resource_type"] == "AWS::CloudFormation::Stack"
    end

    def last_event_status
      @events[0]["resource_status"]
    end

    # Only shows new events
    def show_events(final=false)
      if @last_shown_event_id.nil?
        i = find_index(:start)
        print_events(i)
      else
        i = find_index(:last_shown)
        # puts "last_shown index #{i}"
        print_events(i-1) unless i == 0
      end

      return if final
      sleep 5
      refresh_events
    end

    def print_events(i)
      @events[0..i].reverse.each do |e|
        print_event(e)
      end
      @last_shown_event_id = @events[0]["event_id"]
      # puts "@last_shown_event_id #{@last_shown_event_id.inspect}"
    end

    def print_event(e)
      message = [
        event_time(e["timestamp"]),
        e["resource_status"],
        e["resource_type"],
        e["logical_resource_id"],
        e["resource_status_reason"]
      ].join(" ")
      message = message.colorize(:red) if e["resource_status"] =~ /_FAILED/
      puts message
    end

    # https://stackoverflow.com/questions/18000432/rails-12-hour-am-pm-range-for-a-day
    def event_time(timestamp)
      Time.parse(timestamp.to_s).localtime.strftime("%I:%M:%S%p")
    end

    # refreshes the loaded events in memory
    def refresh_events
      resp = cloudformation.describe_stack_events(stack_name: @stack_name)
      @events = resp["stack_events"]
    rescue Aws::CloudFormation::Errors::ValidationError => e
      if e.message =~ /Stack .* does not exis/
        @stack_deletion_completed = true
      else
        raise
      end
    end

    def find_index(name)
      send("#{name}_index")
    end

    def start_index
      @events.find_index do |event|
        event["resource_type"] == "AWS::CloudFormation::Stack" &&
        event["resource_status_reason"] == "User Initiated"
      end
    end

    def last_shown_index
      @events.find_index do |event|
        event["event_id"] == @last_shown_event_id
      end
    end

    def rename_rollback_error
      begin
        resp = cloudformation.describe_stack_events(stack_name: @stack_name)
      rescue Aws::CloudFormation::Errors::ValidationError => e
        e.message =~ /does not exist/ ? return : raise
      end

      events = resp["stack_events"]
      return unless events[0]["resource_status"] == "UPDATE_ROLLBACK_COMPLETE"

      # find last User Initiated event
      i = events.find_index do |event|
        event["resource_type"] == "AWS::CloudFormation::Stack" &&
        event["resource_status_reason"] == "User Initiated"
      end

      found = events[0..i].reverse.find do |e|
        e["resource_status"] == "UPDATE_FAILED" &&
        e["resource_status_reason"] =~ /CloudFormation cannot update a stack when a custom-named resource requires replacing/
      end
      found["resource_status_reason"] if found
    end
  end
end
