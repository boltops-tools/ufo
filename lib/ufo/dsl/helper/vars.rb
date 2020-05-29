require "aws_data"

class Ufo::DSL::Helper
  class Vars
    extend Memoist

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
        puts "The #{full_path} env file could not be found.  Are you sure it exists?"
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
        item[:valueFrom] = substitute(expand_secret(value))
      end
      secrets
    end

    def expand_secret(value)
      case value
      when /^ssm:/i
        value.sub(/^ssm:/i, "arn:aws:ssm:#{region}:#{account}:parameter/")
      when /^secretsmanager:/i
        value.sub(/^secretsmanager:/i, "arn:aws:secretsmanager:#{region}:#{account}:secret:")
      else
        value # assume full arn has been passed
      end
    end

    def substitute(value)
      value.gsub(":UFO_ENV", Ufo.env)
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

    def aws_data
      AwsData.new
    end
    memoize :aws_data

    def region
      aws_data.region
    end

    def account
      aws_data.account
    end
  end
end
