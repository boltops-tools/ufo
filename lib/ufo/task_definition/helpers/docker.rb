# Core helper methods.
#
# * docker_image - Docker image name to be used when a the docker image is build. This is defined in .ufo/config.rb
# * dockerfile_port - Exposed port in the Dockerfile.  Only supports one exposed port, the first one that is encountered.
#
module Ufo::TaskDefinition::Helpers
  module Docker
    def dockerfile_port
      if File.exist?("Dockerfile")
        port = parse_for_dockerfile_port("Dockerfile")
        return port if port
      end

      # Also consider EXPOSE in Dockerfile.base
      if File.exist?("Dockerfile.base")
        parse_for_dockerfile_port("Dockerfile.base")
      end
    end

    def docker_image
      # Dont need to use @options here. Helps simplify the Helper initialization.
      Ufo::Docker::Builder.new({}).docker_image
    end

    def parse_for_dockerfile_port(dockerfile_path)
      lines = IO.read(dockerfile_path).split("\n")
      expose_line = lines.find { |l| l =~ /^EXPOSE / }
      if expose_line
        md = expose_line.match(/EXPOSE (\d+)/)
        port = md[1] if md
      end
      port.to_i if port
    end
  end
end
