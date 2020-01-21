# Some of variables are from the Dockerfile and some are from other places.
#
# * helper.full_image_name - Docker image name to be used when a the docker image is build. This is defined in ufo/settings.yml.
# * helper.dockerfile_port - Expose port in the Dockerfile.  Only supports one exposed port, the first one that is encountered.

# Simply aggregates a bunch of variables that is useful for the task_definition.
module Ufo
  class DSL
    # provides some helperally context variables
    class Helper
      include Ufo::Util
      extend Memoist

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
      def env_vars(text)
        lines = filtered_lines(text)
        lines.map do |line|
          key,*value = line.strip.split("=").map do |x|
            remove_surrounding_quotes(x.strip)
          end
          value = value.join('=')
          {
            name: key,
            value: value,
          }
        end
      end

      def remove_surrounding_quotes(s)
        if s =~ /^"/ && s =~ /"$/
          s.sub(/^["]/, '').gsub(/["]$/,'') # remove surrounding double quotes
        elsif s =~ /^'/ && s =~ /'$/
          s.sub(/^[']/, '').gsub(/[']$/,'') # remove surrounding single quotes
        else
          s
        end
      end

      def filtered_lines(text)
        lines = text.split("\n")
        # remove comment at the end of the line
        lines.map! { |l| l.sub(/\s+#.*/,'').strip }
        # filter out commented lines
        lines = lines.reject { |l| l =~ /(^|\s)#/i }
        # filter out empty lines
        lines = lines.reject { |l| l.strip.empty? }
      end

      def env_file(path)
        full_path = "#{Ufo.root}/#{path}"
        unless File.exist?(full_path)
          puts "The #{full_path} env file could not be found.  Are you sure it exists?"
          exit 1
        end
        text = IO.read(full_path)
        env_vars(text)
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
