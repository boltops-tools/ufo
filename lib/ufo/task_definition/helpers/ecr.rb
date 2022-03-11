module Ufo::TaskDefinition::Helpers
  module Ecr
    include Ufo::Utils::CallLine

    def ecr_repo(name)
      repository = ecr_repository(name)
      repository.repository_uri if repository
    end

    def ecr_repository(name)
      resp = ecr.describe_repositories(repository_names: [name])
      resp.repositories.first
    rescue Aws::ECR::Errors::RepositoryNotFoundException => e
      call_line = ufo_config_call_line
      logger.warn "WARN: #{e.class} #{e.message}".color(:yellow)
      logger.warn <<~EOL
        Called from

            #{call_line}

      EOL
      nil
    end
  end
end
