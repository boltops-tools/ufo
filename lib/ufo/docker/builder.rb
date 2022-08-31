module Ufo::Docker
  class Builder
    extend Memoist
    include Concerns
    include Ufo::Hooks::Concern

    delegate :push, to: :pusher
    def self.build(options={})
      builder = Builder.new(options) # outside if because it need builder.docker_image
      builder.build
      pusher = Pusher.new(nil, options)
      pusher.push
      builder
    end

    def initialize(options={})
      @options = options
      @dockerfile = options[:dockerfile] || 'Dockerfile'
      @image_namespace = options[:image_namespace] || 'ufo'
    end

    def build
      start_time = Time.now
      store_docker_image

      logger.info "Building Docker Image"
      compile_dockerfile_erb
      check_dockerfile_exists
      update_auth_token
      command = "docker build #{build_options}-t #{docker_image} -f #{@dockerfile} ."
      log = ".ufo/log/docker.log" if @options[:quiet]
      success = nil
      run_hooks(name: "build", file: "docker.rb") do
        success = execute(command, log: log)
      end
      unless success
        docker_version_success = system("docker version > /dev/null 2>&1")
        unless docker_version_success
          docker_version_message = "  Are you sure the docker daemon is available?  Try running: docker version."
        end
        logger.info "ERROR: Fail to build Docker image.#{docker_version_message}".color(:red)
        exit 1
      end

      took = Time.now - start_time
      logger.info "Docker Image built: #{docker_image}"
      logger.info "Took #{pretty_time(took)}"
    end

    def build_options
      options = ENV['UFO_DOCKER_BUILD_OPTIONS']
      options += " " if options
      options
    end

    # Parse Dockerfile for FROM instruction. If the starting image is from an ECR
    # repository, it's likely an private image so we authorize ECR for pulling.
    def update_auth_token
      ecr_image_names = ecr_image_names("#{Ufo.root}/#{@dockerfile}")
      return if ecr_image_names.empty?

      ecr_image_names.each do |ecr_image_name|
        auth = Ufo::Ecr::Auth.new(ecr_image_name)
        # wont update auth token unless the image being pushed in the ECR image format
        auth.update
      end
    end

    def ecr_image_names(path)
      from_image_names(path).select { |i| i =~ /\.amazonaws\.com/ }
    end

    def from_image_names(path)
      lines = IO.readlines(path)
      froms = lines.select { |l| l =~ /^FROM/ }
      froms.map do |l|
        md = l.match(/^FROM (.*)/)
        md[1]
      end.compact
    end

    def pusher
      @pusher ||= Pusher.new(docker_image, @options)
    end

    def compile_dockerfile_erb
      Compiler.new("#{Ufo.root}/#{@dockerfile}").compile # This path does not have .erb
    end
    private :compile_dockerfile_erb

    def compile
      erb_path = "#{Ufo.root}/#{@dockerfile}.erb"
      if File.exist?(erb_path)
        compile_dockerfile_erb
      else
        logger.info "File #{erb_path.color(:green)} does not exist. Cannot compile it if it doesnt exist"
      end
    end

    def check_dockerfile_exists
      unless File.exist?("#{Ufo.root}/#{@dockerfile}")
        logger.info "#{@dockerfile} does not exist.  Are you sure it exists?"
        exit 1
      end
    end

    # full_image - does not include the tag
    def image_name
      Ufo.config.docker.repo
    end

    # full_image - Includes the tag. Examples:
    #   123456789.dkr.ecr.us-west-2.amazonaws.com/myapp:ufo-2018-04-20T09-29-08-b7d51df
    #   org/repo:ufo-2018-04-20T09-29-08-b7d51df
    def docker_image
      return generate_name if @options[:generate]

      unless File.exist?(docker_name_path)
        logger.info <<~EOL.color(:yellow)
          WARN: Unable to find: #{pretty_path(docker_name_path)}
          This contains the Docker image name that the build process uses.
          Please first run:

              ufo docker build

        EOL
        return "docker image not yet built"
      end
      IO.read(docker_name_path).strip
    end

    # Store this in a file because this name gets reference in other tasks later
    # and we want the image name to stay the same when the commands are run separate
    # in different processes.  So we store the state in a file.
    # Only when a new docker build command gets run will the image name state be updated.
    def store_docker_image
      dirname = File.dirname(docker_name_path)
      FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
      docker_image = generate_name
      IO.write(docker_name_path, docker_image)
    end

    def generate_name
      ["#{image_name}:#{@image_namespace}", Ufo.role, Ufo.env, timestamp, git_sha].compact.join('-') # compact in case git_sha is unavailable
    end

    def docker_name_path
      # output gets entirely wiped by tasks builder so dotn use that folder
      "#{Ufo.root}/.ufo/tmp/state/docker_image_name_#{@image_namespace}.txt"
    end

    def timestamp
      Time.now.strftime('%Y-%m-%dT%H-%M-%S')
    end
    memoize :timestamp

    def git_sha
      sha = if File.exist?('.git')
        `git rev-parse --short HEAD`
      elsif ENV['CODEBUILD_RESOLVED_SOURCE_VERSION'] # AWS codebuild
        ENV['CODEBUILD_RESOLVED_SOURCE_VERSION'][0..6] # first 7 chars
      end
      sha.strip if sha
    end
    memoize :git_sha

    def update_dockerfile
      updater = if File.exist?("#{Ufo.root}/Dockerfile.erb") # dont use @dockerfile on purpose
        State.new(@options.merge(base_image: docker_image))
      else
        Dockerfile.new(docker_image, @options)
      end
      updater.update
    end
  end
end
