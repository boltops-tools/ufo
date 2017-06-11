module Ufo
  class Ecr::Auth
    include AwsServices

    def initialize(repo_domain)
      @repo_domain = repo_domain
    end

    def update
      auth_token = fetch_auth_token
      if File.exist?(docker_config)
        data = JSON.load(IO.read(docker_config))
        data["auths"][@repo_domain] = {auth: auth_token}
      else
        data = {auths: {@repo_domain => {auth: auth_token}}}
      end
      ensure_dotdocker_exists
      IO.write(docker_config, JSON.pretty_generate(data))
    end

    def fetch_auth_token
      ecr.get_authorization_token.authorization_data.first.authorization_token
    end

    def docker_config
      "#{ENV['HOME']}/.docker/config.json"
    end

    def ensure_dotdocker_exists
      dirname = File.dirname(docker_config)
      FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
    end

  end
end
