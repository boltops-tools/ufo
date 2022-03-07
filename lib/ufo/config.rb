require "singleton"

module Ufo
  class Config
    extend Memoist
    include DslEvaluator
    include Singleton
    include Ufo::Utils::Logging

    include Ufo::TaskDefinition::Helpers

    attr_reader :config
    def initialize
      @config = defaults
    end

    def defaults
      config = ActiveSupport::OrderedOptions.new

      config.app = nil # required unless UFO_APP is set

      config.autoscaling = ActiveSupport::OrderedOptions.new
      config.autoscaling.enabled = true
      config.autoscaling.max_capacity = 5 # dont use max thats an OrderedOptions method
      config.autoscaling.min_capacity = 1 # dont use min thats an OrderedOptions method
      config.autoscaling.predefined_metric_type = "ECSServiceAverageCPUUtilization"
      config.autoscaling.scale_in_cooldown = nil
      config.autoscaling.scale_out_cooldown = nil
      config.autoscaling.target_value = 75.0

      config.cfn = ActiveSupport::OrderedOptions.new
      config.cfn.disable_rollback = nil
      config.cfn.notification_arns = nil
      config.cfn.tags = nil # should be Ruby Hash

      config.dns = ActiveSupport::OrderedOptions.new
      config.dns.comment = "cname to load balancer created by ufo"
      config.dns.domain = nil # only recommended option to set
      config.dns.hosted_zone_id = nil
      config.dns.hosted_zone_name = nil
      config.dns.name = nil
      config.dns.ttl = 60
      config.dns.type = "CNAME"

      config.docker = ActiveSupport::OrderedOptions.new
      config.docker.clean_keep = nil
      config.docker.ecr_keep = nil
      config.docker.repo = nil # required IE: org/repo basename of the Docker image

      config.ecs = ActiveSupport::OrderedOptions.new
      config.ecs.cluster = ":ENV" # => dev
      config.ecs.deployment_configuration = nil # full control
      config.ecs.desired_count = nil # only respected when config.autoscaling.enabled = false
      config.ecs.maximum_percent = 200 # nil
      config.ecs.minimum_healthy_percent = 100 # nil
      config.ecs.scheduling_strategy = "REPLICA"

      config.elb = ActiveSupport::OrderedOptions.new
      config.elb.default_actions = nil # full override
      config.elb.enabled = "auto" # "auto", true or false

      config.elb.health_check_interval_seconds = 10
      config.elb.health_check_path = nil # When nil its AWS default /
      config.elb.healthy_threshold_count = 5
      config.elb.unhealthy_threshold_count = 2

      config.elb.port = 80 # default listener port
      config.elb.redirect = ActiveSupport::OrderedOptions.new
      config.elb.redirect.code = 302  # IE: 302 or 301
      config.elb.redirect.enabled = false
      config.elb.redirect.port = 443
      config.elb.redirect.protocol = "HTTPS"
      config.elb.ssl = ActiveSupport::OrderedOptions.new
      config.elb.ssl.certificates = nil
      config.elb.ssl.enabled = false
      config.elb.ssl.port = 443
      config.elb.subnet_mappings = nil # static IP addresses for network load balancer
      config.elb.type = "application"

      config.exec = ActiveSupport::OrderedOptions.new
      config.exec.command = "/bin/bash" # aws ecs execute-command cli
      config.exec.enabled = true        # EcsService EnableExecuteCommand

      config.log = ActiveSupport::OrderedOptions.new
      config.log.root = Ufo.log_root
      config.logger = ufo_logger
      config.logger.formatter = Logger::Formatter.new
      config.logger.level = ENV['UFO_LOG_LEVEL'] || :info

      config.logs = ActiveSupport::OrderedOptions.new
      config.logs.filter_pattern = nil

      config.names = ActiveSupport::OrderedOptions.new
      config.names.stack = ":APP-:ROLE-:ENV" # => demo-web-dev
      config.names.task_definition = ":APP-:ROLE-:ENV" # => demo-web-dev

      config.ps = ActiveSupport::OrderedOptions.new
      config.ps.format = "auto" # CliFormat.default_format
      config.ps.hide_age = 5 # in minutes. IE: hide tasks that are older than 5 minutes
      config.ps.summary = true

      config.secrets = ActiveSupport::OrderedOptions.new
      config.secrets.pattern = ActiveSupport::OrderedOptions.new
      config.secrets.pattern.secretsmanager = ":APP-:ENV-:SECRET_NAME" # => demo-dev-DB_PASS
      config.secrets.pattern.ssm = ":APP/:ENV/:SECRET_NAME" # => demo/dev/DB_PASS
      config.secrets.provider = "ssm" # default provider for conventional expansion IE: ssm or secretsmanager

      config.scale = ActiveSupport::OrderedOptions.new
      config.scale.warning = true

      config.ship = ActiveSupport::OrderedOptions.new
      config.ship.docker = ActiveSupport::OrderedOptions.new
      config.ship.docker.quiet = false # only affects ufo ship docker commands output

      config.state = ActiveSupport::OrderedOptions.new
      config.state.reminder = true

      # When not set, the default vpc is used
      config.vpc = ActiveSupport::OrderedOptions.new
      config.vpc.id = nil
      config.vpc.security_groups = ActiveSupport::OrderedOptions.new
      config.vpc.security_groups.ecs = nil
      config.vpc.security_groups.elb = nil
      config.vpc.security_groups.managed = true
      config.vpc.subnets = ActiveSupport::OrderedOptions.new
      config.vpc.subnets.ecs = nil
      config.vpc.subnets.elb = nil

      config
    end

    def ufo_logger
      Logger.new(ENV['UFO_LOG_PATH'] || $stderr)
    end
    memoize :ufo_logger

    def configure
      yield(@config)
    end

    # load_project_config gets called so early many things like logger is not available.
    # Take care not to rely on things that rely on the the config or else will create
    # and infinite loop.
    def load_project_config
      root = layer_levels(".ufo/config")
      env  = layer_levels(".ufo/config/env")
      role = layer_levels(".ufo/config/#{Ufo.role}")
      layers = root + env + role
      # Dont use Ufo.app or that'll cause infinite loop since it loads Ufo.config
      if ENV['UFO_APP']
        root = layer_levels(".ufo/config/#{Ufo.app}")
        env  = layer_levels(".ufo/config/#{Ufo.app}/env")
        role = layer_levels(".ufo/config/#{Ufo.app}/#{Ufo.role}")
        layers += root + env + role
      end
      # load_project_config gets called so early that logger is not yet configured. use puts
      puts "Config layers:" if ENV['UFO_SHOW_ALL_LAYERS']
      layers.each do |layer|
        path = "#{Ufo.root}/#{layer}"
        puts "    #{layer}" if ENV['UFO_SHOW_ALL_LAYERS']
        evaluate_file(path)
      end
    end

    # Works similiar to Layering::Layer. Consider combining the logic and usin Layering::Layer
    #
    # Examples:
    #
    #     prefix: .ufo/config/#{Ufo.app}/env
    #
    # Returns
    #
    #     .ufo/config/#{Ufo.app}/env.rb
    #     .ufo/config/#{Ufo.app}/env/base.rb
    #     .ufo/config/#{Ufo.app}/env/#{Ufo.env}.rb
    #
    def layer_levels(prefix=nil)
      levels = ["", "base", Ufo.env]
      paths = levels.map do |i|
        # base layer has prefix of '', reject with blank so it doesnt produce '//'
        [prefix, i].join('/')
      end
      add_ext!(paths)
    end

      def add_ext!(paths)
      ext = "rb"
      paths.map! do |path|
        path = path.sub(/\/$/,'') if path.ends_with?('/')
        "#{path}.rb"
      end
      paths
    end

end
end
