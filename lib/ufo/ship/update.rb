class Ufo::Ship
  module Update
    # $ aws ecs update-service --generate-cli-skeleton
    # {
    #     "cluster": "",
    #     "service": "",
    #     "taskDefinition": "",
    #     "desiredCount": 0,
    #     "deploymentConfiguration": {
    #         "maximumPercent": 0,
    #         "minimumHealthyPercent": 0
    #     }
    # }
    # Only thing we want to change is the task-definition
    def update_service(ecs_service)
      message = "#{ecs_service.service_name} service updated on #{ecs_service.cluster_name} cluster with task #{@task_definition}"
      if @options[:noop]
        message = "NOOP #{message}"
      else
        params = {
          cluster: ecs_service.cluster_arn, # can use the cluster name also since it is unique
          service: ecs_service.service_arn, # can use the service name also since it is unique
          task_definition: @task_definition
        }
        params = params.merge(default_params[:update_service] || {})
        puts "Updating ECS service with params:"
        display_params(params)
        show_aws_cli_command(:update, params)

        unless @options[:noop]
          response = ecs.update_service(params)
          service = response.service # must set service here since this might never be called if @wait_for_deployment is false
        end
      end

      puts message unless @options[:mute]
      service
    end
  end
end
