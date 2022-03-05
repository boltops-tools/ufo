class Ufo::TaskDefinition::Erb
  class Yaml < Base
    def data
      text = IO.read(@path)
      YAML.load(text)
    rescue Psych::SyntaxError => e
      logger.error "ERROR: #{e.class}: #{e.message}"
      logger.error <<~EOL
        Rendered file contains invalid YAML. For debugging, files available at:

        source:   #{@task_definition.path}
        rendered: #{@path}

      EOL
      print_code(text)
    end
  end
end
