module Ufo
  class DockerfileUpdater
    def initialize(full_image_name, options={})
      @full_image_name = full_image_name
      @options = options
      @project_root = options[:project_root] || '.'
    end

    def update
      write_new_dockerfile
    end

    def current_dockerfile
      @current_dockerfile ||= IO.read(dockerfile_path)
    end

    def dockerfile_path
      "#{@project_root}/Dockerfile"
    end

    def new_dockerfile
      lines = current_dockerfile.split("\n")
      # replace FROM line
      new_lines = lines.map do |line|
                    if line =~ /^FROM /
                      "FROM #{@full_image_name}"
                    else
                      line
                    end
                  end
      new_lines.join("\n") + "\n"
    end

    def write_new_dockerfile
      IO.write(dockerfile_path, new_dockerfile)
      unless @options[:mute]
        puts "The Dockerfile FROM statement has been updated with the latest base image:".green
        puts "  #{@full_image_name}".green
      end
    end
  end
end
