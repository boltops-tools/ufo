module Ufo
  class Task < Base
    extend Memoist

    include Util
    include AwsService

    def initialize(task_definition, options)
      @task_definition = task_definition
      @options = options
      @cluster = @options[:cluster] || default_cluster
    end

    def run
      puts "Running task_definition: #{@task_definition}".colorize(:green) unless @options[:mute]
      return if @options[:noop]

      task_options = {
        cluster: @cluster,
        task_definition: @task_definition
      }
      task_options = adjust_fargate_options(task_options)
      task_options = task_options.merge(user_params[:run_task] || {})
      task_options = adjust_security_groups(task_options)

      if @options[:command]
        task_options.merge!(overrides: overrides)
        puts "Running task with container overrides."
        puts "Command: #{@options[:command].join(' ')}"
      end

      unless @options[:mute]
        puts "Running task with params:"
        display_params(task_options)
      end

      resp = run_task(task_options)
      pp resp
      unless @options[:mute]
        task_arn = resp.tasks[0].task_arn
        puts "Task ARN: #{task_arn}"
        puts "  aws ecs describe-tasks --tasks #{task_arn} --cluster #{@cluster}"
        cloudwatch_info(task_arn)
      end
    end

    def run_task(options)
      puts "Equivalent aws cli command:"
      puts "  aws ecs run-task --cluster #{@cluster} --task-definition #{options[:task_definition]}".colorize(:green)
      ecs.run_task(options)
    # rescue Aws::ECS::Errors::ClientException => e
    #   if e.message =~ /ECS was unable to assume the role/
    #     puts "ERROR: #{e.class} #{e.message}".colorize(:red)
    #     puts "Please double check the executionRoleArn in your task definition."
    #     exit 1
    #   else
    #     raise
    #   end
    # rescue Aws::ECS::Errors::InvalidParameterException => e
    #   if e.message =~ /Network Configuration must be provided when networkMode 'awsvpc' is specified/
    #     puts "ERROR: #{e.class} #{e.message}".colorize(:red)
    #     puts "Please double check .ufo/params.yml and make sure that network_configuration is set."
    #     puts "Or run change the task definition template in .ufo/templates so it does not use vpcmode."
    #     exit 1
    #   else
    #     raise
    #   end
    end

  private
    # adjust network_configuration based on fargate and network mode of awsvpc
    def adjust_fargate_options(options)
      return options
      task_def = recent_task_definition

      if task_def[:network_mode] == "awsvpc"
        awsvpc_conf = { subnets: network[:ecs_subnets] }
      end

      fargate_enabled = task_def[:requires_compatibilities] == ["FARGATE"]
      if fargate_enabled
        awsvpc_conf[:assign_public_ip] = "ENABLED"
      end
      options[:network_configuration] = { awsvpc_configuration: awsvpc_conf }

      if fargate_enabled
        options[:launch_type] = "FARGATE"
      end
      options
    end

    # Ensures at least 1 security group is assigned if awsvpc_configuration
    # is provided.
    def adjust_security_groups(options)
      return options unless options[:network_configuration] &&
                     options[:network_configuration][:awsvpc_configuration]

      awsvpc_conf = options[:network_configuration][:awsvpc_configuration]

      security_groups = awsvpc_conf[:security_groups]
      if [nil, '', 'nil'].include?(security_groups)
        security_groups = []
      end
      if security_groups.empty?
        fetch = Network::Fetch.new(network[:vpc])
        sg = fetch.security_group_id
        security_groups << sg
        security_groups.uniq!
      end

      # override security groups
      options[:network_configuration][:awsvpc_configuration][:security_groups] = security_groups
      options
    end

    def network
      settings = Ufo.settings
      Setting::Profile.new(:network, settings[:network_profile]).data
    end
    memoize :network

    def cloudwatch_info(task_arn)
      config = container_definition[:log_configuration]
      container_name = container_definition[:name]

      return unless config && config[:log_driver] == "awslogs"

      log_group = config[:options]["awslogs-group"]
      log_stream_prefix = config[:options]["awslogs-stream-prefix"]
      task_id = task_arn.split('/').last
      log_stream = "#{log_stream_prefix}/#{container_name}/#{task_id}"
      # website/web/d473440a-9a0e-4262-a53d-f9e345cf2b7e
      region = `aws configure get region`.strip rescue 'us-east-1'
      url = "https://#{region}.console.aws.amazon.com/cloudwatch/home?region=#{region}#logEventViewer:group=#{log_group};stream=#{log_stream}"

      puts "To see the task output visit CloudWatch:\n  #{url}"
      puts "NOTE: It will take some time for the log to show up because it takes time for the task to start. Run the `aws ecs describe-tasks` above for the task status."
    end

    # only using the overrides to override the container command
    def overrides
      command = @options[:command] # Thor parser ensure this is always an array
      {
        container_overrides: [
          {
            name: container_definition[:name],
            command: command,
            environment: container_definition[:environment],
          },
        ]
      }
    end

    # Usually most recent task definition.
    # If user has specified task_definition with specific version like
    #   demo-web:8
    # Then it'll be that exact task definnition.
    def recent_task_definition
      arns = task_definition_arns(@task_definition)
      # "arn:aws:ecs:us-east-1:<aws_account_id>:task-definition/wordpress:6",
      last_definition_arn = arns.first
      puts "last_definition_arn #{last_definition_arn}"
      task_name = last_definition_arn.split("/").last
      resp = ecs.describe_task_definition(task_definition: task_name)

      resp.task_definition
    end
    memoize :recent_task_definition

    # container definition from the most recent task definition
    def container_definition
      recent_task_definition.container_definitions[0].to_h
    end
  end
end
