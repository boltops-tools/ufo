=begin
Normally, you must authorized to AWS ECR to push to their registry with:

  eval $(aws ecr get-login --no-include-email)

If you haven't ever ran the ecr get-login command before then you'll get this error:

  no basic auth credentials

If you have ran it before but the auto token has expired you'll get this message:

  denied: Your Authorization Token has expired. Please run 'aws ecr get-login' to fetch a new one.

This class manipulates the ~/.docker/config.json file which is an internal docker file to automatically update the auto token for you.  If that format changes, the update will need to be updated.
=end
module Ufo
  class Ecr::Auth
    include AwsService

    def initialize(full_image_name)
      @full_image_name = full_image_name
      @repo_domain = "#{full_image_name.split('/').first}"
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

    def ecr_image?
      !!(@full_image_name =~ /\.amazonaws\.com/)
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
