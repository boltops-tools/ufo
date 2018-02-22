require 'colorize'

module Ufo
  class UfoError < RuntimeError; end
  class ShipmentOverridden < UfoError; end

  class Ship
    include Default
    include AwsService
    include Util

    def initialize(service, task_definition, options={})
      @service = service
      @task_definition = task_definition
      @options = options
      @target_group_prompt = @options[:target_group_prompt].nil? ? true : @options[:target_group_prompt]
      @cluster = @options[:cluster] || default_cluster
      @wait_for_deployment = @options[:wait].nil? ? true : @options[:wait]
      @stop_old_tasks = @options[:stop_old_tasks].nil? ? false : @options[:stop_old_tasks]
    end

    def deploy
      message = "Shipping #{@service}..."
      unless @options[:mute]
        if @options[:noop]
          puts "NOOP: #{message}"
          return
        else
          puts message.green
        end
      end

      ensure_log_group_exist
      ensure_cluster_exist
      process_deployment

      puts "Software shipped!" unless @options[:mute]
    end

    def ensure_log_group_exist
      LogGroup.new(@task_definition, @options).create
    end

    def process_deployment
      ecs_service = find_ecs_service
      deployed_service = if ecs_service
                           # update all existing service
                           update_service(ecs_service)
                         else
                           # create service on the first cluster
                           create_service
                         end

      wait_for_deployment(deployed_service) if @wait_for_deployment && !@options[:noop]
      stop_old_task(deployed_service) if @stop_old_tasks
    end

    def service_tasks(cluster, service)
      all_task_arns = ecs.list_tasks(cluster: cluster, service_name: service).task_arns
      return [] if all_task_arns.empty?
      ecs.describe_tasks(cluster: cluster, tasks: all_task_arns).tasks
    end

    def old_task?(deployed_task_definition_arn, task_definition_arn)
      puts "deployed_task_definition_arn: #{deployed_task_definition_arn.inspect}"
      puts "task_definition_arn: #{task_definition_arn.inspect}"
      deployed_version = deployed_task_definition_arn.split(':').last.to_i
      version = task_definition_arn.split(':').last.to_i
      puts "deployed_version #{deployed_version.inspect}"
      puts "version #{version.inspect}"
      is_old = version < deployed_version
      puts "is_old #{is_old.inspect}"
      is_old
    end

    def stop_old_tasks(services)
      services.each do |service|
        stop_old_task(service)
      end
    end

    # aws ecs list-tasks --cluster prod-hi --service-name gr-web-prod
    # aws ecs describe-tasks --tasks arn:aws:ecs:us-east-1:467446852200:task/09038fd2-f989-4903-a8c6-1bc41761f93f --cluster prod-hi
    def stop_old_task(deployed_service)
      deployed_task_definition_arn = deployed_service.task_definition
      puts "deployed_task_definition_arn #{deployed_task_definition_arn.inspect}"

      # cannot use @serivce because of multiple mode
      all_tasks = service_tasks(@cluster, deployed_service.service_name)
      old_tasks = all_tasks.select do |task|
        old_task?(deployed_task_definition_arn, task.task_definition_arn)
      end

      reason = "Ufo #{Ufo::VERSION} has deployed new code and waited until the newer code is running."
      puts reason
      # Stopping old tasks after we have confirmed that the new task definition has the same
      # number of desired_count and running_count speeds up clean up and ensure that we
      # dont have any stale code being served.  It seems to take a long time for the
      # ELB to drain the register container otherwise. This might cut off some requests but
      # providing this as an option that can be turned of beause I've seen deploys go way too
      # slow.
      puts "@options[:stop_old_tasks] #{@options[:stop_old_tasks].inspect}"
      puts "old_tasks.size #{old_tasks.size}"
      old_tasks.each do |task|
        puts "stopping task.task_definition_arn #{task.task_definition_arn.inspect}"
        ecs.stop_task(cluster: @cluster, task: task.task_arn, reason: reason)
      end if @options[:stop_old_tasks]
    end

    # service is the returned object from aws-sdk not the @service which is just a String.
    # Returns [service_name, time_took]
    def wait_for_deployment(deployed_service, quiet=false)
      start_time = Time.now
      deployed_task_name = task_name(deployed_service.task_definition)
      puts "Waiting for deployment of task definition #{deployed_task_name.green} to complete" unless quiet
      begin
        until deployment_complete(deployed_service)
          print '.'
          sleep 5
        end
      rescue ShipmentOverridden => e
        puts "This deployed was overridden by another deploy"
        puts e.message
      end
      puts '' unless quiet
      took = Time.now - start_time
      puts "Time waiting for ECS deployment: #{pretty_time(took).green}." unless quiet
      [deployed_service.service_name, took]
    end

    def wait_for_all_deployments(deployed_services)
      start_time = Time.now
      threads = deployed_services.map do |deployed_service|
        Thread.new do
          # http://stackoverflow.com/questions/1383390/how-can-i-return-a-value-from-a-thread-in-ruby
          Thread.current[:output] = wait_for_deployment(deployed_service, quiet=true)
        end
      end
      threads.each { |t| t.join }
      total_took = Time.now - start_time
      puts ""
      puts "Shipments for all #{deployed_service.size} services took a total of #{pretty_time(total_took).green}."
      puts "Each deployment took:"
      threads.each do |t|
        service_name, took = t[:output]
        puts "  #{service_name}: #{pretty_time(took)}"
      end
    end

    # used for polling
    # must pass in a service and cannot use @service for the case of multi_services mode
    def find_updated_service(service)
      ecs.describe_services(services: [service.service_name], cluster: @cluster).services.first
    end

    # aws ecs describe-services --services hi-web-prod --cluster prod-hi
    # Passing in the service because we need to capture the deployed task_definition
    # that was actually deployed.   We use it to pull the describe_services
    # until all the paramters we expect upon a completed deployment are updated.
    #
    def deployment_complete(deployed_service)
      deployed_task_definition = deployed_service.task_definition # want the stale task_definition out of the wa
      service = find_updated_service(deployed_service) # polling
      deployment = service.deployments.first
      # Edge case when another deploy superseds this deploy in this case break out of this loop
      deployed_task_version = task_version(deployed_task_definition)
      current_task_version = task_version(service.task_definition)
      if current_task_version > deployed_task_version
        raise ShipmentOverridden.new("deployed_task_version was #{deployed_task_version} but task_version is now #{current_task_version}")
      end

      (deployment.task_definition == deployed_task_definition &&
       deployment.desired_count == deployment.running_count)
    end

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
          desired_count: default_desired_count,
          deployment_configuration: {
            maximum_percent: default_maximum_percent,
            minimum_healthy_percent: default_minimum_healthy_percent
          },
          task_definition: @task_definition
        }
        unless target_group.nil? || target_group.empty?
          add_load_balancer!(container, options, target_group)
        end
        response = ecs.create_service(options)
        service = response.service # must set service here since this might never be called if @wait_for_deployment is false
      end
      puts message unless @options[:mute]
      service
    end

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
        response = ecs.update_service(params)
        service = response.service # must set service here since this might never be called if @wait_for_deployment is false
      end
      puts message unless @options[:mute]
      service
    end

    # Only support Application Load Balancer
    # Think there is an AWS bug that complains about not having the LB
    # name but you cannot pass both a LB Name and a Target Group.
    def add_load_balancer!(container, options, target_group)
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
    def target_group_prompt(container)
      return if @options[:noop]
      # If a target_group is provided at the CLI return it right away.
      return @options[:target_group] if @options[:target_group]
      # Allows skipping the target group prompt.
      return unless @target_group_prompt

      # If the container name is web then it is assume that this is a web service that
      # needs a target group/elb.
      return unless container[:name] == 'web'

      puts "Would you like this service to be associated with an Application Load Balancer?"
      puts "If yes, please provide the Application Load Balancer Target Group ARN."
      puts "If no, simply press enter."
      print "Target Group ARN: "

      arn = $stdin.gets.strip
      until arn == '' or validate_target_group(arn)
        puts "You have provided an invalid Application Load Balancer Target Group ARN: #{arn}."
        puts "It should be in the form: arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/target-name/2378947392743"
        puts "Please try again or skip adding a Target Group by just pressing enter."
        print "Target Group ARN: "
        arn = $stdin.gets.strip
      end
      arn
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

    def find_ecs_service
      find_all_ecs_services.find { |ecs_service| ecs_service.service_name == @service }
    end

    # find all services on a cluster
    # yields Ufo::ECS::Service object
    def find_all_ecs_services
      ecs_services = []
      service_arns.each do |service_arn|
        ecs_service = Ufo::ECS::Service.new(cluster_arn, service_arn)
        yield(ecs_service) if block_given?
        ecs_services << ecs_service
      end
      ecs_services
    end

    def service_arns
      services = ecs.list_services(cluster: @cluster)
      list_service_arns = services.service_arns
      while services.next_token != nil
        services = ecs.list_services(cluster: @cluster, next_token: services.next_token)
        list_service_arns += services.service_arns
      end
      list_service_arns
    end

    def cluster_arn
      @cluster_arn ||= ecs_clusters.first.cluster_arn
    end

    def ensure_cluster_exist
      cluster_exist = ecs_clusters.first
      unless cluster_exist
        message = "#{@cluster} cluster created."
        if @options[:noop]
          message = "NOOP #{message}"
        else
          ecs.create_cluster(cluster_name: @cluster)
          # TODO: Aad Waiter logic, sometimes the cluster does not exist by the time
          # we create the service
        end
        puts message unless @options[:mute]
      end
    end

    def ecs_clusters
      ecs.describe_clusters(clusters: [@cluster]).clusters
    end

    def task_name(task_definition)
      # "arn:aws:ecs:us-east-1:123456789:task-definition/hi-web-prod:72"
      #   ->
      # "task-definition/hi-web-prod:72"
      task_definition.split('/').last
    end

    def task_version(task_definition)
      # "task-definition/hi-web-prod:72" -> 72
      task_name(task_definition).split(':').last.to_i
    end
  end
end
