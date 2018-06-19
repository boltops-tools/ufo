require 'colorize'

module Ufo
  class UfoError < RuntimeError; end
  class ShipmentOverridden < UfoError; end

  class Ship
    autoload :Create, "ufo/ship/create"
    autoload :Update, "ufo/ship/update"

    include AwsService
    include Util
    include Create
    include Update
    include SecurityGroup::Helper

    def initialize(service, task_definition, options={})
      @service = service
      @task_definition = task_definition
      @options = options
      @cluster = @options[:cluster] || default_cluster
      @wait_for_deployment = @options[:wait].nil? ? true : @options[:wait]
      @stop_old_tasks = @options[:stop_old_tasks].nil? ? false : @options[:stop_old_tasks]
    end

    def deploy
      message = "Deploying #{@service}..."
      unless @options[:mute]
        if @options[:noop]
          puts "NOOP: #{message}"
          return
        else
          puts message.green
        end
      end

      # TODO: COMMENT OUT FOR TESTING
      # ensure_log_group_exist
      # ensure_cluster_exist
      process_deployment

      puts "Software shipped!" unless @options[:mute]
    end

    def ensure_log_group_exist
      LogGroup.new(@task_definition, @options).create
    end

    def process_deployment
      options = @options.merge(
        stack_name: @service,
        service: @service,
        task_definition: @task_definition,
      )
      stack = Stack.new(options)
      stack.launch
      # ecs_service = find_ecs_service
      # deployed_service = if ecs_service
      #                      # update all existing service
      #                      update_service(ecs_service)
      #                    else
      #                      # create service on the first cluster
      #                      create_service
      #                    end

      # wait_for_deployment(deployed_service) if @wait_for_deployment && !@options[:noop]
      # stop_old_task(deployed_service) if @stop_old_tasks
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

    def show_aws_cli_command(action, params)
      puts "Equivalent aws cli command:"
      # Use .ufo/data instead of .ufo/output because output files all get looped
      # through as part of `ufo tasks register`
      rel_path = ".ufo/data/#{action}-params.json"
      output_path = "#{Ufo.root}/#{rel_path}"
      FileUtils.rm_f(output_path)

      # Thanks: https://www.mnishiguchi.com/2017/11/29/rails-hash-camelize-and-underscore-keys/
      params = params.deep_transform_keys { |key| key.to_s.camelize(:lower) }
      json = JSON.pretty_generate(params)
      IO.write(output_path, json)

      file_path = "file://#{rel_path}"
      puts "  aws ecs #{action}-service --cli-input-json #{file_path}".colorize(:green)
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
      cluster = ecs_clusters.first
      unless cluster && cluster.status == "ACTIVE"
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
