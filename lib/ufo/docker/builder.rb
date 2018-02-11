module Ufo
  class Docker::Builder
    include Util

    def self.build(options)
      builder = Docker::Builder.new(options) # outside if because it need builder.full_image_name
      if options[:docker]
        builder.build
        builder.push
      end
      builder
    end

    def initialize(options={})
      @options = options
      @project_root = options[:project_root] || '.'
      @dockerfile = options[:dockerfile] || 'Dockerfile'
      @image_namespace = options[:image_namespace] || 'ufo'
    end

    def build
      start_time = Time.now
      store_full_image_name
      update_auth_token # call after store_full_image_name

      command = "docker build -t #{full_image_name} -f #{@dockerfile} ."
      say "Building docker image with:".green
      say "  #{command}".green
      check_dockerfile_exists
      command = "cd #{@project_root} && #{command}"
      success = execute(command, use_system: true)
      unless success
        puts "ERROR: The docker image fail to build.  Are you sure the docker daemon is available?  Try running: docker version".colorize(:red)
        exit 1
      end

      took = Time.now - start_time
      say "Docker image #{full_image_name} built.  " + "Took #{pretty_time(took)}.".green
    end

    def push
      update_auth_token
      start_time = Time.now
      message = "Pushed #{full_image_name} docker image."
      if @options[:noop]
        message = "NOOP #{message}"
      else
        command = "docker push #{full_image_name}"
        puts "=> #{command}".colorize(:green)
        success = execute(command, use_system: true)
        unless success
          puts "ERROR: The docker image fail to push.".colorize(:red)
          exit 1
        end
      end
      took = Time.now - start_time
      message << " Took #{pretty_time(took)}.".green
      puts message unless @options[:mute]
    end

    def check_dockerfile_exists
      unless File.exist?("#{@project_root}/#{@dockerfile}")
        puts "#{@dockerfile} does not exist.  Are you sure it exists?"
        exit 1
      end
    end

    def update_auth_token
      return unless ecr_image?
      repo_domain = "https://#{image_name.split('/').first}"
      auth = Ecr::Auth.new(repo_domain)
      auth.update
    end

    def ecr_image?
      full_image_name =~ /\.amazonaws\.com/
    end

    # full_image - does not include the tag
    def image_name
      setting.data["image"]
    end

    # full_image - includes the tag
    def full_image_name
      if @options[:generate]
        return generate_name # name already has a newline
      end

      return "tongueroo/hi:ufo-12345678" if ENV['TEST']

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
      "#{@project_root}/ufo/data/docker_image_name_#{@image_namespace}.txt"
    end

    def timestamp
      @timestamp ||= Time.now.strftime('%Y-%m-%dT%H-%M-%S')
    end

    def git_sha
      return @git_sha if @git_sha
      # always call this and dont use the execute method because of the noop option
      @git_sha = `cd #{@project_root} && git rev-parse --short HEAD`
      @git_sha.strip!
    end

    def setting
      @setting ||= Setting.new(@project_root)
    end

    def update_dockerfile
      dockerfile = Docker::Dockerfile.new(full_image_name, @options)
      dockerfile.update
    end

    def say(msg)
      puts msg unless @options[:mute]
    end
  end
end
