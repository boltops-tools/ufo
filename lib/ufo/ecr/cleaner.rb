require "json"

module Ufo
  class Ecr::Cleaner
    include Ufo::AwsServices
    include Ufo::Utils::Execute
    include Ufo::Utils::Logging

    def initialize(docker_image_name, options={})
      # docker_image_name does not containg the tag
      # Example: 123456789.dkr.ecr.us-east-1.amazonaws.com/image
      @docker_image_name = docker_image_name
      @options = options
      @keep = options[:ecr_keep] || Ufo.config.docker.ecr_keep
      @tag_prefix = options[:tag_prefix] || "ufo"
    end

    def cleanup
      return false unless @keep
      return false unless ecr_image?
      update_auth_token
      image_tags = fetch_image_tags
      delete_tags = image_tags[@keep..-1] # ordered by most recent images first
      delete_images(delete_tags)
    end

    def fetch_image_tags
      ecr.list_images(repository_name: repo_name).
        image_ids.
        map { |image_id| image_id.image_tag }.
        select { |image_tag| image_tag =~ Regexp.new("^#{@tag_prefix}-") }.
        sort.reverse
    end

    def delete_images(tags)
      return if tags.nil? || tags.empty?
      logger.info "Keeping #{@keep} most recent ECR images."
      logger.info "Deleting these ECR images:"
      tag_list = tags.map { |t| "  #{repo_name}:#{t}" }
      logger.info tag_list
      image_ids = tags.map { |tag| {image_tag: tag} }
      ecr.batch_delete_image(
        repository_name: repo_name,
        image_ids: image_ids)
    end

    def update_auth_token
      repo_domain = "#{@docker_image_name.split('/').first}"
      auth = Ecr::Auth.new(repo_domain)
      auth.update
    end

    def repo_name
      # @docker_image_name example: 123456789.dkr.ecr.us-east-1.amazonaws.com/image
      @docker_image_name.split('/').last
    end

    def ecr_image?
      @docker_image_name =~ /\.amazonaws\.com/
    end
  end
end
