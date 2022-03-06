require 'ostruct'

class Ufo::TaskDefinition
  class Erb < Ufo::CLI::Base
    extend Memoist
    include Context

    delegate :name, :role, to: :task_definition
    alias_method :task_definition_name, :name
    alias_method :family, :name

    def run
      logger.debug "Building Task Definition"
      clean
      load_context
      data = evaluate_code
      check_empty!(data)
      data = squeeze(data)
      write(data)
      logger.info "Task Definition built: #{output_path}"
    end

    def check_empty!(data)
      if data.nil?
        logger.error "ERROR: Unable to compile the YAML".color(:red) # invalid YAML will result in data == nil
        exit 1
      end

      return unless data == true || data == false || data.empty?
      logger.error "ERROR: Empty task definition results".color(:red)
      logger.error <<~EOL
        The resulting task definition is empty.
        Please double check that the task definition code is not empty.

            #{pretty_path(@task_definition.path)}

      EOL
      exit 1
    end

    def evaluate_code
      path = @task_definition.path
      text = RenderMePretty.result(path, context: self)
      rendered_path = "/tmp/ufo/task_definition#{File.extname(path)}"
      FileUtils.mkdir_p(File.dirname(rendered_path))
      IO.write(rendered_path, text)

      o = @options.merge(path: rendered_path, task_definition: @task_definition)
      if path.ends_with?('.json')
        Json.new(o).data
      else
        Yaml.new(o).data
      end
    end

    def squeeze(data)
      Ufo::Utils::Squeezer.new(data).squeeze
    end

    def write(data)
      data = override_image(data)
      json = JSON.pretty_generate(data)
      FileUtils.mkdir_p(File.dirname(output_path))
      IO.write(output_path, json)
    end

    def override_image(data)
      return data unless @options[:image]
      data["containerDefinitions"].each do |container_definition|
        container_definition["image"] = @options[:image]
      end
      data
    end

    def output_path
      "#{Ufo.root}/.ufo/output/task_definition.json".sub(/^\.\//,'') # remove leading ./
    end

    def clean
      FileUtils.rm_rf("#{Ufo.root}/.ufo/output")
    end
  end
end
