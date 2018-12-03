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
        puts "Command: #{command_in_human_readable_form}"
      end

      unless @options[:mute]
        puts "Running task with params:"
        display_params(task_options)
      end

      ensure_log_group_exist

      resp = run_task(task_options)
      exit_if_failures!(resp)
      unless @options[:mute]
        task_arn = resp.tasks[0].task_arn
        puts "Task ARN: #{task_arn}"
        puts "  aws ecs describe-tasks --tasks #{task_arn} --cluster #{@cluster}"
        cloudwatch_info(task_arn)
      end
    end

    def ensure_log_group_exist
      LogGroup.new(@task_definition, @options).create
    end

    # Pretty hard to produce this edge case.  Happens when:
    #   launch_type: EC2
    #   network_mode: awsvpc
    #   assign_public_ip: DISABLED
    def exit_if_failures!(resp)
      return if resp[:failures].nil? || resp[:failures].empty?

      puts "There was a failure running the ECS task.".colorize(:red)
      puts "This might be happen if you have a network_mode of awsvpc and have assigned_public_ip to DISABLED."
      puts "This cryptic error also shows up if the network settings have security groups and subnets that are not in the same vpc as the ECS cluster container instances.  Please double check that."
      puts "You can use this command to quickly reconfigure the network settings:"
      puts "  ufo network init --vpc-id XXX."
      puts "More details on the can be found under the 'Task Networking Considerations' section at: "
      puts "https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html"
      puts "Original response with failures:"
      pp resp
      exit 1
    end

    def run_task(options)
      puts "Equivalent aws cli command:"
      puts "  aws ecs run-task --cluster #{@cluster} --task-definition #{options[:task_definition]}".colorize(:green)
      run_task_result = ecs.run_task(options)
      if @options[:wait]
        task_arn = run_task_result.tasks[0].task_arn
        raise SystemExit, exit_status_of_task(task_arn)
      else
        run_task_result
      end
    rescue Aws::ECS::Errors::ClientException => e
      if e.message =~ /ECS was unable to assume the role/
        puts "ERROR: #{e.class} #{e.message}".colorize(:red)
        puts "Please double check the executionRoleArn in your task definition."
        exit 1
      else
        raise
      end
    rescue Aws::ECS::Errors::InvalidParameterException => e
      if e.message =~ /Network Configuration must be provided when networkMode 'awsvpc' is specified/
        puts "ERROR: #{e.class} #{e.message}".colorize(:red)
        puts "Please double check .ufo/params.yml and make sure that network_configuration is set."
        puts "Or run change the task definition template in .ufo/templates so it does not use vpcmode."
        exit 1
      else
        raise
      end
    end

  private
    # adjust network_configuration based on fargate and network mode of awsvpc
    def adjust_fargate_options(options)
      task_def = recent_task_definition
      return options unless task_def[:network_mode] == "awsvpc"

      awsvpc_conf = { subnets: network[:ecs_subnets] }
      if task_def[:requires_compatibilities] == ["FARGATE"]
        awsvpc_conf[:assign_public_ip] = "ENABLED"
        options[:launch_type] = "FARGATE"
      end

      options[:network_configuration] = { awsvpc_configuration: awsvpc_conf }
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
      # puts "last_definition_arn #{last_definition_arn}"
      task_name = last_definition_arn.split("/").last
      resp = ecs.describe_task_definition(task_definition: task_name)

      resp.task_definition
    end
    memoize :recent_task_definition

    # container definition from the most recent task definition
    def container_definition
      recent_task_definition.container_definitions[0].to_h
    end

    def exit_status_of_task(task_arn)
      waiter_max_attempts = @options[:timeout] / 5
      waiter_delay = 5 # seconds long polling.

      print "Waiting for task to complete."
      ecs.wait_until(:tasks_stopped, { cluster: @cluster, tasks: [task_arn] }) do |waiter|
        waiter.before_wait { print '.' }
        waiter.delay = waiter_delay
        waiter.max_attempts = waiter_max_attempts
      end
      puts
      container = ecs.describe_tasks(cluster: @cluster, tasks: [task_arn]).tasks[0].containers[0]

      container.exit_code.nil? ? 1 : container.exit_code
    rescue Aws::Waiters::Errors::WaiterFailed
      puts "It took longer than #{options[:timeout]} seconds to run #{command_in_human_readable_form} (#{task_arn})"
      exit 1
    end

    def command_in_human_readable_form
      @options[:command].join(' ')
    end
  end
end
