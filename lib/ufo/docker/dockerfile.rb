module Ufo::Docker
  class Dockerfile
    include Ufo::Utils::Logging

    def initialize(docker_image, options={})
      @docker_image, @options = docker_image, options
    end

    def update
      write_new_dockerfile
    end

    def current_dockerfile
      @current_dockerfile ||= IO.read(dockerfile_path)
    end

    def dockerfile_path
      "#{Ufo.root}/Dockerfile"
    end

    def new_dockerfile
      lines = current_dockerfile.split("\n")
      # replace FROM line
      new_lines = lines.map do |line|
                    if line =~ /^FROM /
                      "FROM #{@docker_image}"
                    else
                      line
                    end
                  end
      new_lines.join("\n") + "\n"
    end

    def write_new_dockerfile
      IO.write(dockerfile_path, new_dockerfile)
      logger.debug <<~EOL
        The Dockerfile FROM statement has been updated with the latest base image:

            #{@docker_image}

      EOL
    end
  end
end
