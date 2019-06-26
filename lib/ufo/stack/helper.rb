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
      if settings[:stack_naming].nil?
        puts "WARN: In ufo v4.5 the UFO_ENV value gets appends to the end of the CloudFormation stack name.  This means a new stack gets created. You must upgrade to using the new stack and delete the old stack manually.  More info: https://ufoships.com/docs/upgrading/upgrade4.5/".color(:yellow)
        puts "To get rid of this warning you can add `stack_naming: append_ufo_env` to your `.ufo/settings.yml config. New versions of ufo init do this automatically."
        puts "Pausing for 20 seconds."
        sleep 20
      end

      parts = case settings[:stack_naming]
      when "prepend_cluster" # ufo v4.3 and below
        [cluster, service, Ufo.env_extra] # legacy
      when "append_env", "append_cluster" # ufo v4.5
        # append_env will be removed in the next major version in favor of append_cluster to avoid confusion with
        # append_ufo_env
        [service, cluster, Ufo.env_extra]
      when "append_nothing", "prepend_nothing"
        [service, Ufo.env_extra]
      else # new default. ufo v4.5 and above
        [service, Ufo.env, Ufo.env_extra]
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
