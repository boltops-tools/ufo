class Ufo::Cfn::Stack
  class Params < Ufo::Cfn::Stack::Builder::Base
    def build
      params = {
        Vpc: vpc.id,
        ElbSubnets: vpc.elb_subnets,
        EcsSubnets: vpc.ecs_subnets,

        CreateElb: vars[:create_elb] ? "true" : "false",
        ElbTargetGroup: vars[:elb_target_group].to_s,

        EcsSchedulingStrategy: Ufo.config.ecs.scheduling_strategy,
      }
      params[:EcsDesiredCount] = desired_count.to_s if desired_count # Note: cfn template is type String so it can be optional

      params = Ufo::Utils::Squeezer.new(params).squeeze
      parameters = params.map do |k,v|
        if v == :use_previous_value
          { parameter_key: k, use_previous_value: true }
        else
          { parameter_key: k, parameter_value: v }
        end
      end
      save_params(parameters)
      parameters
    end

  private
    def desired_count
      Ufo.config.ecs.desired_count
    end

    # No need to save template. That's already saved.
    def save_params(parameters)
      params = parameters.dup.map do |param|
        param.transform_keys do |key|
          key.to_s.camelize
        end
      end
      path = "#{Ufo.root}/.ufo/output/params.json"
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, JSON.pretty_generate(params))
      logger.info "Parameters built:      #{pretty_path(path)}"
    end

    def vpc
      Vpc.new(@options)
    end
    memoize :vpc
  end
end
