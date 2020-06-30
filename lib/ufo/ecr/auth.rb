require 'open3'

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
      # wont update auth token unless the image being pushed in the ECR image format
      return unless ecr_image?

      auth_token = fetch_auth_token
      username, password = Base64.decode64(auth_token).split(':')

      command = "docker login -u #{username} --password-stdin #{@repo_domain}"
      puts "=> #{command}".color(:green)
      *, status = Open3.capture3(command, stdin_data: password)
      unless status.success?
        puts "ERROR: The docker failed to login.".color(:red)
        exit 1
      end
    end

    def ecr_image?
      !!(@full_image_name =~ /\.amazonaws\.com/)
    end

    def fetch_auth_token
      ecr.get_authorization_token.authorization_data.first.authorization_token
    end

  end
end
