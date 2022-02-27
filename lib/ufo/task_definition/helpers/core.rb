# Core helper methods.
#
# * docker_image - Docker image name to be used when a the docker image is build. This is defined in .ufo/config.rb
# * dockerfile_port - Exposed port in the Dockerfile.  Only supports one exposed port, the first one that is encountered.
#
module Ufo::TaskDefinition::Helpers
  module Core
    extend Memoist

    def dockerfile_port
      dockerfile_path = "#{Ufo.root}/Dockerfile"
      if File.exist?(dockerfile_path)
        parse_for_dockerfile_port(dockerfile_path)
      end
    end

    def docker_image
      # Dont need to use @options here. Helps simplify the Helper initialization.
      Ufo::Docker::Builder.new({}).docker_image
    end

    def env(text)
      Vars.new(text: text).env
    end
    alias_method :env_vars, :env
    alias_method :environment, :env

    def env_file(path)
      Vars.new(file: path).env
    end

    def secrets(text)
      Vars.new(text: text).secrets
    end

    def secrets_file(path)
      Vars.new(file: path).secrets
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
