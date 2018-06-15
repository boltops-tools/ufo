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
      target_group = target_group_prompt(container)

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
  end
end
