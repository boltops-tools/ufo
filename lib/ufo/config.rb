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
      config.autoscaling.manual_changes = ActiveSupport::OrderedOptions.new
      config.autoscaling.manual_changes.retain = false
      config.autoscaling.manual_changes.warning = true
      config.autoscaling.max_capacity = 5 # dont use max thats an OrderedOptions method
      config.autoscaling.min_capacity = 1 # dont use min thats an OrderedOptions method
      config.autoscaling.predefined_metric_type = "ECSServiceAverageMemoryUtilization"
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

      config.elb.existing = ActiveSupport::OrderedOptions.new
      config.elb.existing.target_group = nil
      config.elb.existing.dns_name = nil # for managed route53 records

      config.elb.health_check_interval_seconds = 10 # keep at 10 in case of network ELB, which is min 10
      config.elb.health_check_path = nil # When nil its AWS default /
      config.elb.healthy_threshold_count = 3 # The AWS usual default is 5
      config.elb.unhealthy_threshold_count = 3

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

      config.hooks = ActiveSupport::OrderedOptions.new
      config.hooks.show = true

      config.layering = ActiveSupport::OrderedOptions.new
      config.layering.show = parsed_layering_show
      config.layering.show_for_commands = parsed_layering_show_for

      config.log = ActiveSupport::OrderedOptions.new
      config.log.root = Ufo.log_root
      config.logger = ufo_logger
      config.logger.formatter = Logger::Formatter.new
      config.logger.level = ENV['UFO_LOG_LEVEL'] || :info

      config.logs = ActiveSupport::OrderedOptions.new
      config.logs.filter_pattern = nil

      config.names = ActiveSupport::OrderedOptions.new
      config.names.stack = ":APP-:ROLE-:ENV-:EXTRA" # => demo-web-dev
      config.names.task_definition = ":APP-:ROLE-:ENV-:EXTRA" # => demo-web-dev

      config.ps = ActiveSupport::OrderedOptions.new
      config.ps.format = "auto" # CliFormat.default_format
      config.ps.hide_age = 5 # in minutes. IE: hide tasks that are older than 5 minutes
      config.ps.summary = true

      config.secrets = ActiveSupport::OrderedOptions.new
      config.secrets.manager_pattern = ":APP/:ENV/:SECRET_NAME" # => demo/dev/DB_PASS
      config.secrets.ssm_pattern = ":APP/:ENV/:SECRET_NAME" # => demo/dev/DB_PASS
      config.secrets.provider = "ssm" # default provider for conventional expansion IE: ssm or secretsmanager

      config.ship = ActiveSupport::OrderedOptions.new
      config.ship.docker = ActiveSupport::OrderedOptions.new
      config.ship.docker.quiet = false # only affects ufo ship docker commands output

      config.state = ActiveSupport::OrderedOptions.new
      config.state.bucket = nil # Set to use existing bucket. When not set ufo creates a managed s3 bucket
      config.state.managed = true # false will disable creation of managed bucket entirely
      config.state.reminder = true
      config.state.storage = "s3" # s3 or file

      config.waf = ActiveSupport::OrderedOptions.new
      config.waf.web_acl_arn = nil

      # When not set, the default vpc is used
      config.vpc = ActiveSupport::OrderedOptions.new
      config.vpc.id = nil
      config.vpc.security_groups = ActiveSupport::OrderedOptions.new
      config.vpc.security_groups.ecs = nil
      config.vpc.security_groups.elb = nil
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
      # load_project_config gets called so early that logger is not yet configured.
      # Cannot use Ufo.config yet and cannot use logger which relies on Ufo.config
      # Use puts and use parsed_layering_show
      show = show_layers?
      puts "Config Layers" if show
      layers.each do |layer|
        path = "#{Ufo.root}/#{layer}"
        if ENV['UFO_LAYERS_ALL']
          puts "    #{pretty_path(path)}"
        elsif show
          puts "    #{pretty_path(path)}" if File.exist?(path)
        end
        evaluate_file(path)
      end
    end

    def show_layers?
      show_for = parsed_layering_show_for
      command = ARGV[0]
      parsed_layering_show && show_for.include?(command)
    end

    def parsed_layering_show_for
      parse.for("layering.show_for_commands", type: :array) || %w[build ship] # IE: ps exec logs are not shown
    end
    memoize :parsed_layering_show_for

    def parsed_layering_show
      ENV['UFO_LAYERS'] || parse.for("layering.show", type: :boolean)
    end
    private :parsed_layering_show

    def parse
      Parse.new
    end
    memoize :parse

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
      levels << "#{Ufo.env}-#{Ufo.extra}" if Ufo.extra
      paths = levels.map do |i|
        # base layer has prefix of '', reject with blank so it doesnt produce '//'
        [prefix, i].join('/')
      end
      add_ext!(paths)
    end

    def add_ext!(paths)
      paths.map! do |path|
        path = path.sub(/\/$/,'') if path.ends_with?('/')
        "#{path}.rb"
      end
      paths
    end
  end
end
