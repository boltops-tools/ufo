require 'active_support/core_ext/module/delegation'

class Ufo::Docker
  class Builder
    include Ufo::Util

    delegate :push, to: :pusher
    def self.build(options)
      builder = Builder.new(options) # outside if because it need builder.full_image_name
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
      store_full_image_name

      update_auth_token

      command = "docker build #{build_options}-t #{full_image_name} -f #{@dockerfile} ."
      say "Building docker image with:".green
      say "  #{command}".green
      check_dockerfile_exists
      command = "cd #{Ufo.root} && #{command}"
      success = execute(command, use_system: true)
      unless success
        docker_version_success = system("docker version > /dev/null 2>&1")
        unless docker_version_success
          docker_version_message = "  Are you sure the docker daemon is available?  Try running: docker version."
        end
        puts "ERROR: The docker image fail to build.#{docker_version_message}".colorize(:red)
        exit 1
      end

      took = Time.now - start_time
      say "Docker image #{full_image_name} built.  "
      say "Docker build took #{pretty_time(took)}.".green
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
      @pusher ||= Pusher.new(full_image_name, @options)
    end

    def check_dockerfile_exists
      unless File.exist?("#{Ufo.root}/#{@dockerfile}")
        puts "#{@dockerfile} does not exist.  Are you sure it exists?"
        exit 1
      end
    end

    # full_image - does not include the tag
    def image_name
      settings[:image]
    end

    # full_image - Includes the tag. Examples:
    #   123456789.dkr.ecr.us-west-2.amazonaws.com/myapp:ufo-2018-04-20T09-29-08-b7d51df
    #   tongueroo/demo-ufo:ufo-2018-04-20T09-29-08-b7d51df
    def full_image_name
      return generate_name if @options[:generate]
      return "tongueroo/demo-ufo:ufo-12345678" if ENV['TEST']

      unless File.exist?(docker_name_path)
        puts "Unable to find #{docker_name_path} which contains the last docker image name that was used as a part of `ufo docker build`.  Please run `ufo docker build` first."
        exit 1
      end
      IO.read(docker_name_path).strip
    end

    # Store this in a file because this name gets reference in other tasks later
    # and we want the image name to stay the same when the commands are run separate
    # in different processes.  So we store the state in a file.
    # Only when a new docker build command gets run will the image name state be updated.
    def store_full_image_name
      dirname = File.dirname(docker_name_path)
      FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
      full_image_name = generate_name
      IO.write(docker_name_path, full_image_name)
    end

    def generate_name
      "#{image_name}:#{@image_namespace}-#{timestamp}-#{git_sha}"
    end

    def docker_name_path
      # output gets entirely wiped by tasks builder so dotn use that folder
      "#{Ufo.root}/.ufo/data/docker_image_name_#{@image_namespace}.txt"
    end

    def timestamp
      @timestamp ||= Time.now.strftime('%Y-%m-%dT%H-%M-%S')
    end

    def git_sha
      return @git_sha if @git_sha
      # always call this and dont use the execute method because of the noop option
      @git_sha = `cd #{Ufo.root} && git rev-parse --short HEAD`
      @git_sha.strip!
    end

    def update_dockerfile
      dockerfile = Dockerfile.new(full_image_name, @options)
      dockerfile.update
    end

    def say(msg)
      puts msg unless @options[:mute]
    end
  end
end
