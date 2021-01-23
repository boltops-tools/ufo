class Ufo::Stack
  module Helper
    include Ufo::AwsService
    include Ufo::Util
    include Ufo::Settings
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
      when "append_cluster" # ufo v4.5
        # append_env will be removed in the next major version in favor of append_cluster to avoid confusion with
        # append_ufo_env
        [service, cluster, Ufo.env_extra]
      when "append_env" # ufo v5.0.3 and below: append_env is a bug, it appends cluster name instead of env name
        puts "WARN: Deprecation: The append_env is depreciated .ufo/settings.yaml".color(:yellow)
        puts "It appends the cluster env instead of the UFO_ENV env. This is unexpected behavior. "
        puts "To been fix this, please `stack_naming: append_ufo_env` instead. "
        [service, cluster, Ufo.env_extra] # bug - kept for backward compatibility
      when "append_ufo_env"  # v5.1.0 fixes bug where append_env would append cluster name instead
        [service, Ufo.env, Ufo.env_extra]
      when "append_nothing", "prepend_nothing"
        [service, Ufo.env_extra]
      else # new default. ufo v4.5 and above
        [service, Ufo.env.to_s, Ufo.env_extra]
      end
      parts.reject {|x| x==''}.compact.join('-') # stack_name
    end

    def status
      Status.new(@stack_name)
    end
    memoize :status
  end
end
