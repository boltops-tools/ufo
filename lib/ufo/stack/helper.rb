class Ufo::Stack
  module Helper
    include Ufo::AwsService
    include Ufo::Util
    extend Memoist

    def find_stack(stack_name)
      resp = cloudformation.describe_stacks(stack_name: stack_name)
      resp.stacks.first
    rescue Aws::CloudFormation::Errors::ValidationError => e
      # example: Stack with id demo-web does not exist
      if e.message =~ /Stack with/ && e.message =~ /does not exist/
        nil
      else
        raise
      end
    end

    def adjust_stack_name(cluster, service)
      if settings[:stack_naming] != "append_env"
        puts "WARN: In ufo v4.4 the environment name gets appends to the end of the CloudFormation stack name.  This means a new stack gets created. You must upgrade to using the new stack and delete the old stack manually.  More info: http://ufoships.com/docs/upgrading/upgrade4.4/".color(:yellow)
        puts "To get rid of this warning you can add `stack_naming: append_env` to your `.ufo/settings.yml config. New versions of ufo init does this automatically."
        puts "Pausing for 20 seconds."
        sleep 20
      end

      parts = if settings[:stack_naming] == "append_env"
        [service, cluster, Ufo.env_extra]
      else
        # legacy, to be removed in next major version
        [cluster, service, Ufo.env_extra]
      end
      parts.reject {|x| x==''}.compact.join('-') # stack_name
    end

    def cfn
      Ufo::Setting::Profile.new(:cfn, settings[:cfn_profile]).data
    end

    def status
      Status.new(@stack_name)
    end
    memoize :status
  end
end
