module Ufo::TaskDefinition::Helpers::Ssm
  class Fetcher
    include Ufo::AwsServices
    include Ufo::Utils::Logging
    include Ufo::Concerns::Names

    def initialize(options={})
      @options = options
      @base64 = options[:base64]
    end

    def fetch(name)
      name = names.expansion(name, dasherize: false)
      parameter = fetch_parameter(name)
      return unless parameter
      value = parameter.value
      value = Base64.strict_encode64(value).strip if base64?(parameter.type)
      value
    end

    def base64?(type)
      if @base64.nil?
        type == "SecureString"
      else
        @base64
      end
    end

    # Note: Cannot use logger if since if ssm helper is used in config it'll cause an infinite loop
    def fetch_parameter(name)
      resp = ssm_client.get_parameter(name: name, with_decryption: true)
      resp.parameter
    rescue Aws::SSM::Errors::ParameterNotFound => e
      puts "WARN: name #{name} not found".color(:yellow)
      puts e.message
      nil
    end
  end
end
