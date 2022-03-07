module Ufo::TaskDefinition::Helpers
  module Ecr
    def ecr_repo(name)
      repository = ecr_repository(name)
      repository.repository_uri
    end

    def ecr_repository(name)
      resp = ecr.describe_repositories(repository_names: [name])
      resp.repositories.first
    end
  end
end
