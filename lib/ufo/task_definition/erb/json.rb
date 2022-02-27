class Ufo::TaskDefinition::Erb
  class Json < Base
    def data
      text = IO.read(@path)
      JSON.load(text)
    rescue JSON::ParserError => e
      # NOTE: JSON::ParserError e.message is not very useful
      logger.error "ERROR: #{e.class}".color(:red)
      logger.error <<~EOL
        Rendered file contains invalid JSON. For debugging, files available at:

        source:   #{@task_definition.path}
        rendered: #{@path}

      EOL
      logger.error "Contents of the rendered file:\n\n"
      print_code(text)
      if jq_available?
        system "cat #{@path} | jq"
      end
      exit 1
    end

    def jq_available?
      system("type jq > /dev/null 2>&1")
    end
  end
end
