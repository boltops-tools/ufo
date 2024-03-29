module Ufo::Docker
  class Cleaner
    include Ufo::Utils::Execute
    include Ufo::Utils::Logging

    def initialize(docker_image_name, options)
      # docker_image_name does not containg the tag
      # Example: 123456789.dkr.ecr.us-east-1.amazonaws.com/image
      @docker_image_name = docker_image_name
      @options = options
      @keep = Ufo.config.docker.clean_keep
      @tag_prefix = options[:tag_prefix] || "ufo"
    end

    def cleanup
      return if @keep.nil?
      return if delete_list.empty?
      command = "docker rmi #{delete_list}"
      logger.info "Cleaning docker images"
      return if @options[:noop]
      execute(command, quiet: true)
    end

    def delete_list
      return if @keep.nil?
      return [] if ENV['TEST'] || @options[:noop]
      return @delete_list if @delete_list

      out = execute("docker images") # live to override the noop cli options

      name_regexp = Regexp.new(@docker_image_name)
      # Example tag: ufo-2016-10-19T00-36-47-211b63a
      tag_string = "#{@tag_prefix}-\\d{4}-\\d{2}-\\d{2}T\\d{2}-\\d{2}-\\d{2}-.{7}"
      tag_regexp = Regexp.new(tag_string)
      filtered_out = out.split("\n").select do |line|
        name,tag = line.split(' ')
        name =~ name_regexp && tag =~ tag_regexp
      end

      tags = filtered_out.map { |l| l.split(' ')[1] } # 2nd column is tag
      tags = tags.sort.reverse  # ordered by most recent images first
      delete_tags = tags[@keep..-1]
      if delete_tags.nil?
        @delete_list = []
      else
        @delete_list = delete_tags.map { |t| "#{@docker_image_name}:#{t}" }.join(' ')
      end
    end
  end
end
