require "aws_data"

module Ufo::TaskDefinition::Helpers::Vars
  class Builder
    extend Memoist
    include Ufo::Concerns::Names
    include Ufo::Config::CallableOption::Concern
    include Ufo::TaskDefinition::Helpers::AwsHelper
    include Ufo::Utils::CallLine
    include Ufo::Utils::Logging
    include Ufo::Utils::Pretty

    def initialize(options={})
      # use either file or text. text takes higher precedence
      @file = options[:file]
      @text = options[:text]
    end

    def content
      @text if @text
      read(*find_files)
    end

    # Not considering .env files in project root since this is more for deployment
    # Also ufo supports a smarter format than the normal .env files
    def find_files
      return @file if @file
      layers = [
        "base",
        "#{Ufo.env}",
        "#{Ufo.app}",
        "#{Ufo.app}/base",
        "#{Ufo.app}/#{Ufo.env}",
        "#{Ufo.app}/#{Ufo.role}",
        "#{Ufo.app}/#{Ufo.role}/base",
        "#{Ufo.app}/#{Ufo.role}/#{Ufo.env}",
      ]
      layers.map! { |l| ".ufo/env_files/#{l}#{@ext}" }
      show_layers(layers)
      layers.select { |l| File.exist?(l) }
    end

    def show_layers(paths)
      paths.each do |path|
        if ENV['UFO_LAYERS_ALL']
          logger.info "    #{path}"
        elsif Ufo.config.layering.show
          logger.info "    #{path} "if File.exist?(path)
        end
      end
    end

    def read(*paths)
      text= ""
      paths.compact.each do |path|
        text << IO.read("#{Ufo.root}/#{path}")
        text << "\n"
      end
      text
    end

    def env(ext='.env')
      @ext = ext # assign instance variable so dont have to pass around
      result = render_erb(content) # tricky: use result instead of content for variable assignment or content method is not called
      lines = filtered_lines(result)
      lines.map do |line|
        line = line.sub('export ', '') # allow user to use export. ufo ignores it
        key,*value = line.strip.split("=").map do |x|
          remove_surrounding_quotes(x.strip)
        end
        value = value.join('=')
        # Note: env vars do NOT support valueFrom
        # Docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_environment
        {
          name: key,
          value: value,
        }
      end
    end

    def secrets
      secrets = env('.secrets')
      secrets.map do |item|
        value = item.delete(:value)
        arn = normalize_to_arn(item[:name], value)
        value = expansion(arn)
        value = autofix(value)
        item[:valueFrom] = value
      end
      secrets
    end

    def autofix(value)
      value = value.sub('parameter//','parameter/') # auto fix accidental leading slash for user
      if value.include?(':secret:') && value.count(':') == 7 # missing trailing ::
        value += "::"
      end
      value
    end

    def normalize_to_arn(name, value)
      case value
      when /^ssm:/i
        value.sub(/^ssm:/i, "arn:aws:ssm:#{region}:#{account}:parameter/")
      when /^secretsmanager:/i
        value.sub(/^secretsmanager:/i, "arn:aws:secretsmanager:#{region}:#{account}:secret:")
      when '', *available_providers # blank string will mean use convention
        conventional_pattern(name, value)
      else
        value # assume full arn has been passed
      end
    end

    # arn:aws:ssm:us-west-2:111111111111:parameter/demo/dev/DB-NAME
    # arn:aws:ssm:us-west-2:111111111111:parameter/demo/dev/DB-NAME
    def expansion(arn)
      md = arn.match(/(.*:)(parameter\/|secret:)(.*)/)
      if md
        prefix, type, name = md[1], md[2], md[3]
        # performance improvement only run names.expansion on the name portion
        expanded_name = names.expansion(name, dasherize: false) # dasherize: false. dont turn SECRET_NAME => SECRET-NAME
        "#{prefix}#{type}#{expanded_name}"
      else # not arn full value. In case user accidentally puts value in .secrets file KEY=value
        names.expansion(arn, dasherize: false) # dasherize: false. dont turn SECRET_NAME => SECRET-NAME
      end
    end

    # Examples with config.secrets.provider = "ssm"
    #
    # .secrets
    #
    #      DB_NAME
    #
    # Results
    #
    #      DB_NAME=:APP/:ENV/:SECRET_NAME # expansion will use => demo/dev/DB_NAME
    #
    def conventional_pattern(name, value)
      provider = get_provider(value)
      namespace = provider == "ssm" ? "parameter/" : "secret:"

      field = provider == "secretsmanager" ? "manager_pattern" : "ssm_pattern"
      config_name = "secrets.#{field}"
      pattern = callable_option(
        config_name: config_name, # Ufo.config.names.stack => :APP-:ROLE-:ENV => demo-web-dev
        passed_args: [self],
      )
      # replace :SECRET_NAME since names expand doesnt know how to nor do we want to add logic there
      pattern = pattern.sub(':SECRET_NAME', name)
      "arn:aws:#{provider}:#{region}:#{account}:#{namespace}#{pattern}"
    end

    # Allows user to override one-off value. IE: DB_PASS=secretsmanager
    # Note there's no point in disabling this override ability since valueFrom examples a reference.
    #
    #     {
    #       "name": "PASS",
    #       "valueFrom": "arn:aws:ssm:us-west-2:1111111111111:parameter/demo/dev/PASS"
    #     }
    #
    def get_provider(value)
      available_providers.include?(value) ? value : Ufo.config.secrets.provider
    end

    def available_providers
      %w[ssm secretsmanager]
    end

    def remove_surrounding_quotes(s)
      if s =~ /^"/ && s =~ /"$/
        s.sub(/^["]/, '').gsub(/["]$/,'') # remove surrounding double quotes
      elsif s =~ /^'/ && s =~ /'$/
        s.sub(/^[']/, '').gsub(/[']$/,'') # remove surrounding single quotes
      else
        s
      end
    end

    def filtered_lines(content)
      lines = content.split("\n")
      # remove comment at the end of the line
      lines.map! { |l| l.sub(/\s+#.*/,'').strip }
      # filter out commented lines
      lines = lines.reject { |l| l =~ /(^|\s)#/i }
      # filter out empty lines
      lines = lines.reject { |l| l.strip.empty? }
    end

    def render_erb(content)
      path = ".ufo/output/params.erb"
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, content)
      RenderMePretty.result(path, context: self)
    end
  end
end
