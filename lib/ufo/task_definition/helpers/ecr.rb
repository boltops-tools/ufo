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
      logger.warn "WARN: #{e.class} #{e.message}".color(:yellow)
      call_line = ufo_config_call_line
      DslEvaluator.print_code(call_line)
      nil
    end
  end
end
