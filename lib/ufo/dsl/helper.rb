# Some of variables are from the Dockerfile and some are from other places.
#
# * helper.full_image_name - Docker image name to be used when a the docker image is build. This is defined in ufo/settings.yml.
# * helper.dockerfile_port - Expose port in the Dockerfile.  Only supports one exposed port, the first one that is encountered.

# Simply aggregates a bunch of variables that is useful for the task_definition.
module Ufo
  class DSL
    # provides some helperally context variables
    class Helper
      def initialize(options={})
        @options = options
        @project_root = options[:project_root] || '.'
      end

      ##############
      # helper variables
      def dockerfile_port
        dockerfile_path = "#{@project_root}/Dockerfile"
        if File.exist?(dockerfile_path)
          parse_for_dockerfile_port(dockerfile_path)
        end
      end

      def full_image_name
        Docker::Builder.new(@options).full_image_name
      end

      #############
      # helper methods
      def env_vars(text)
        lines = filtered_lines(text)
        lines.map do |line|
          key,value = line.strip.split("=").map {|x| x.strip}
          {
            name: key,
            value: value,
          }
        end
      end

      def filtered_lines(text)
        lines = text.split("\n")
        # remove comment at the end of the line
        lines.map! { |l| l.sub(/#.*/,'').strip }
        # filter out commented lines
        lines = lines.reject { |l| l =~ /(^|\s)#/i }
        # filter out empty lines
        lines = lines.reject { |l| l.strip.empty? }
      end

      def env_file(path)
        full_path = "#{@project_root}/#{path}"
        unless File.exist?(full_path)
          puts "The #{full_path} env file could not be found.  Are you sure it exists?"
          exit 1
        end
        text = IO.read(full_path)
        env_vars(text)
      end

      def current_region
        return 'us-east-1' if ENV['TEST']
        @current_region ||= `aws configure get region`.strip rescue 'us-east-1'
      end

      def setting
        @setting ||= Setting.new(@project_root)
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
