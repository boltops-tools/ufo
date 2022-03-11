require "aws_data"

module Ufo::TaskDefinition::Helpers
  class Vars
    extend Memoist
    include AwsHelper
    include Ufo::Concerns::Names
    include Ufo::Utils::Pretty
    include Ufo::Config::CallableOption::Concern

    def initialize(options={})
      # use either file or text. text takes higher precedence
      @file = options[:file]
      @text = options[:text]
    end

    def content
      @text || read(@file)
    end

    def read(path)
      full_path = "#{Ufo.root}/#{path}"
      unless File.exist?(full_path)
        puts "The #{pretty_path(full_path)} env file could not be found.  Are you sure it exists?"
        exit 1
      end
      IO.read(full_path)
    end

    def env
      lines = filtered_lines(content)
      lines.map do |line|
        key,*value = line.strip.split("=").map do |x|
          remove_surrounding_quotes(x.strip)
        end
        value = value.join('=')
        {
          name: key,
          value: value,
        }
      end
    end

    def secrets
      secrets = env
      secrets.map do |item|
        value = item.delete(:value)
        arn = normalize_to_arn(item[:name], value)
        value = expansion(arn)
        value = value.sub('parameter//','parameter/') # auto fix accidental leading slash for user
        item[:valueFrom] = value
      end
      secrets
    end

    def normalize_to_arn(name, value)
      case value
      when /^ssm:/i
        value.sub(/^ssm:/i, "arn:aws:ssm:#{region}:#{account}:parameter/")
      when /^secretsmanager:/i
        value.sub(/^secretsmanager:/i, "arn:aws:secretsmanager:#{region}:#{account}:secret:")
      when '' # blank string will mean use convention
        conventional_pattern(name, value)
      else
        value # assume full arn has been passed
      end
    end

    # arn:aws:ssm:us-west-2:111111111111:parameter/demo/dev/DB-NAME
    # arn:aws:ssm:us-west-2:111111111111:parameter/demo/dev/DB-NAME
    def expansion(arn)
      # performance improvement only run names.expansion on the name portion
      md = arn.match(/(.*:)(parameter\/|secret:)(.*)/)
      prefix, type, name = md[1], md[2], md[3]
      expanded_name = names.expansion(name, dasherize: false) # dasherize: false. dont turn SECRET_NAME => SECRET-NAME
      "#{prefix}#{type}#{expanded_name}"
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
      secrets = Ufo.config.secrets
      provider = secrets.provider # ssm or secretsmanager
      namespace = provider == "ssm" ? "parameter/" : "secret:"

      config_name = "secrets.pattern.#{provider}"
      pattern = callable_option(
        config_name: config_name, # Ufo.config.names.stack => :APP-:ROLE-:ENV => demo-web-dev
        passed_args: [self],
      )
      # replace :SECRET_NAME since names expand doesnt know how to nor do we want to add logic there
      pattern = pattern.sub(':SECRET_NAME', name)
      "arn:aws:#{provider}:#{region}:#{account}:#{namespace}#{pattern}"
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
  end
end
