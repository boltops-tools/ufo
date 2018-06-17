class Ufo::Ship
  module Create
    # $ aws ecs create-service --generate-cli-skeleton
    # {
    #     "cluster": "",
    #     "serviceName": "",
    #     "taskDefinition": "",
    #     "desiredCount": 0,
    #     "loadBalancers": [
    #         {
    #             "targetGroupArn": "",
    #             "containerName": "",
    #             "containerPort": 0
    #         }
    #     ],
    #     "role": "",
    #     "clientToken": "",
    #     "deploymentConfiguration": {
    #         "maximumPercent": 0,
    #         "minimumHealthyPercent": 0
    #     }
    # }
    #
    # If the service needs to be created it will get created with some default settings.
    # When does a normal deploy where an update happens only the only thing that ufo
    # will update is the task_definition.  The other settings should normally be updated with
    # the ECS console.  `ufo scale` will allow you to updated the desired_count from the
    # CLI though.
    def create_service
      puts "This service #{@service.colorize(:green)} does not yet exist in the #{@cluster.colorize(:green)} cluster.  This deploy will create it."
      container = container_info(@task_definition)

      target_group = determine_target_group(container)

      message = "#{@service} service created on #{@cluster} cluster"
      if @options[:noop]
        message = "NOOP #{message}"
      else
        options = {
          cluster: @cluster,
          service_name: @service,
          task_definition: @task_definition
        }
        options = options.merge(default_params[:create_service])

        unless target_group.nil? || target_group.empty?
          add_load_existing_balancer!(container, options, target_group)
        end

        # auto created security group
        security_group.create
        options = security_group.add_security_group_option(options)

        puts "Creating ECS service with params:"
        display_params(options)
        show_aws_cli_command(:create, options)
        response = ecs.create_service(options)
        service = response.service # must set service here since this might never be called if @wait_for_deployment is false
      end

      puts message unless @options[:mute]
      service
    end

    # Only support Application Load Balancer
    # Think there is an AWS bug that complains about not having the LB
    # name but you cannot pass both a LB Name and a Target Group.
    def add_load_existing_balancer!(container, options, target_group)
      options.merge!(
        load_balancers: [
          {
            container_name: container[:name],
            container_port: container[:port],
            target_group_arn: target_group,
          }
        ]
      )
    end

    # Returns the target_group.
    # Will only allow an target_group and the service to use a load balancer
    # if the container name is "web".
    def determine_target_group(container)
      return if @options[:noop]
      # If a target_group is provided at the CLI return it right away.
      return @options[:target_group] if @options[:target_group]
      # Allows skipping the target group prompt. Wont use or create a load balancer.
      prompt = @options[:target_group_prompt].nil? ? true : @options[:target_group_prompt]
      return unless prompt

      # If the container name is web then it is assume that this is a web service that
      # needs a target group/elb.
      return unless container[:name] == 'web' && @options[:elb] != "false"

      if @options[:elb].nil?
        puts <<-EOL

This ECS service being deployed has a container name: web.
Usually load balancers are associated with web services. Would you like
1. For ufo to automatically create an ELB for you. (yes) [default]
2. Provide Target Group group for an existing ELB. (arn)
3. Do not associate an ELB with this service at all. (no)

For #1, type 'yes' or simply press enter.
For #2, provide the target group arn.
For #3, type 'no'
  EOL

        print "Answer: "
        answer = $stdin.gets.strip
      else
        answer = "yes"
      end

      case answer
      when '', 'yes' # default is to create an ELB
        arn = create_load_balancer # returns target_group_arn
      when 'none', 'no', 'false'
        return nil
      when /arn:aws:elasticloadbalancing/
        arn = answer
        unless validate_target_group(arn)
          puts "You have provided an invalid Application Load Balancer Target Group ARN: #{arn}."
          exit 1
        end
      else
        puts "Invalid answer: #{answer.inspect}"
        puts "Exiting."
        exit 1
      end

      arn
    end

    # all options controlled by balancer profile to keep ufo interface simple
    def create_load_balancer
      balancer = Balancer::Create.new(name: @service)
      balancer.run
      balancer.target_group_arn
    end

    def validate_target_group(arn)
      elb.describe_target_groups(target_group_arns: [arn])
      true
    rescue Aws::ElasticLoadBalancingV2::Errors::ValidationError
      false
    end

    # assume only 1 container_definition
    # assume only 1 port mapping in that container_defintion
    def container_info(task_definition)
      Ufo.check_task_definition!(task_definition)
      task_definition_path = ".ufo/output/#{task_definition}.json"
      task_definition = JSON.load(IO.read(task_definition_path))
      container_def = task_definition["containerDefinitions"].first
      mappings = container_def["portMappings"]
      if mappings
        map = mappings.first
        port = map["containerPort"]
      end
      {
        name: container_def["name"],
        port: port
      }
    end
  end
end
