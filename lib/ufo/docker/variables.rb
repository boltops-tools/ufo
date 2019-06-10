class Ufo::Docker
  class Variables
    @@variables_path = "#{Ufo.root}/.ufo/settings/dockerfile_variables.yml"

    def initialize(full_image_name, options={})
      @full_image_name, @options = full_image_name, options
    end

    def update
      data = current_data
      data[Ufo.env] ||= {}
      data[Ufo.env]["base_image"] = @full_image_name
      pretty_path = @@variables_path.sub("#{Ufo.root}/", "")
      IO.write(@@variables_path, YAML.dump(data))

      unless @options[:mute]
        puts "The #{pretty_path} base_image has been updated with the latest base image:".color(:green)
        puts "  #{@full_image_name}".color(:green)
      end
    end

    def current_data
      File.exist?(@@variables_path) ? YAML.load_file(@@variables_path) : {}
    end
  end
end
