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

      command = "docker build -t #{full_image_name} -f #{@dockerfile} ."
      say "Building docker image with:".green
      say "  #{command}".green
      check_dockerfile_exists
      command = "cd #{Ufo.root} && #{command}"
      success = execute(command, use_system: true)
      unless success
        puts "ERROR: The docker image fail to build.  Are you sure the docker daemon is available?  Try running: docker version".colorize(:red)
        exit 1
      end

      took = Time.now - start_time
      say "Docker image #{full_image_name} built.  " + "Took #{pretty_time(took)}.".green
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
      setting.data["image"]
    end

    # full_image - includes the tag
    def full_image_name
      return generate_name if @options[:generate]
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

    def setting
      @setting ||= Ufo::Setting.new(Ufo.root)
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
