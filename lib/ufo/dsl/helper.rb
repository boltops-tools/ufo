# Some of variables are from the Dockerfile and some are from other places.
#
# * helper.full_image_name - Docker image name to be used when a the docker image is build. This is defined in ufo/settings.yml.
# * helper.dockerfile_port - Expose port in the Dockerfile.  Only supports one exposed port, the first one that is encountered.

# Simply aggregates a bunch of variables that is useful for the task_definition.
module Ufo
  class DSL
    class Helper
      include Ufo::Util
      extend Memoist

      # Add helpers from .ufo/helpers folder
      def add_project_helpers
        helpers_dir = "#{Ufo.root}/.ufo/helpers"
        Dir.glob("#{helpers_dir}/**/*").each do |path|
          next unless File.file?(path)
          klass = path.gsub(%r{.*\.ufo/helpers/},'').sub(".rb",'').camelize
          self.class.send(:include, klass.constantize)
        end
      end

      ##############
      # helper variables
      def dockerfile_port
        dockerfile_path = "#{Ufo.root}/Dockerfile"
        if File.exist?(dockerfile_path)
          parse_for_dockerfile_port(dockerfile_path)
        end
      end

      def full_image_name
        # Dont need to use @options here. Helps simplify the Helper initialization.
        Docker::Builder.new({}).full_image_name
      end

      #############
      # helper methods
      def env(text)
        Vars.new(text: text).env
      end
      alias_method :env_vars, :env

      def env_file(path)
        Vars.new(file: path).env
      end

      def secrets(text)
        Vars.new(text: text).secrets
      end

      def secrets_file(path)
        Vars.new(file: path).secrets
      end

      def current_region
        default_region = 'us-east-1'
        return default_region if ENV['TEST']

        return ENV['UFO_AWS_REGION'] if ENV['UFO_AWS_REGION'] # highest precedence
        return ENV['AWS_REGION'] if ENV['AWS_REGION']

        region = `aws configure get region`.strip rescue default_region
        region.blank? ? default_region : region
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
end
