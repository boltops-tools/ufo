class Ufo::TaskDefinition::Erb
  class Yaml < Base
    def data
      text = IO.read(@path)
      YAML.load(text)
    rescue Psych::SyntaxError => e
      logger.error "ERROR: #{e.class}: #{e.message}".color(:red)
      logger.error <<~EOL
        Rendered file contains invalid YAML. For debugging, files available at:

        source:   #{@task_definition.path}
        rendered: #{@path}

      EOL

      md = e.message.match(/at line (\d+) column (\d+)/)
      if md
        line_number = md[1]
        DslEvaluator.print_code(@path, line_number)
      else
        print_code(text) # fallback to simpler print code if cannot find line numbers
      end
    end
  end
end
