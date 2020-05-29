module Ufo
  class DSL
    class Outputter
      def initialize(name, erb_result, options={})
        @name = name
        @erb_result = erb_result
        @options = options
      end

      def write
        output_path = "#{Ufo.root}/.ufo/output"
        FileUtils.rm_rf(output_path) if @options[:clean]
        FileUtils.mkdir(output_path) unless File.exist?(output_path)

        path = "#{output_path}/#{@name}.json".sub(/^\.\//,'')
        puts "  #{path}" unless @options[:quiet]
        validate(@erb_result, path)
        data = JSON.parse(@erb_result)
        override_image(data)
        json = JSON.pretty_generate(data)
        File.open(path, 'w') {|f| f.write(json) }
      end

      def override_image(data)
        return data unless @options[:image_override]
        data["containerDefinitions"].each do |container_definition|
          container_definition["image"] = @options[:image_override]
        end
      end

      def validate(json, path)
        begin
          JSON.parse(json)
        rescue JSON::ParserError => e
          puts "#{e.class}: #{e.message}"
          puts "Invalid json.  Output written to #{path} for debugging".color(:red)
          File.open(path, 'w') {|f| f.write(json) }
          exit 1
        end
      end
    end
  end
end
