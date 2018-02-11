module Ufo
  class DSL
    class Outputter
      def initialize(name, erb_result, options={})
        @name = name
        @erb_result = erb_result
        @options = options
        @pretty = options[:pretty].nil? ? true : options[:pretty]
      end

      def write
        output_path = "#{Ufo.root}/.ufo/output"
        FileUtils.rm_rf(output_path) if @options[:clean]
        FileUtils.mkdir(output_path) unless File.exist?(output_path)

        path = "#{output_path}/#{@name}.json".sub(/^\.\//,'')
        puts "  #{path}" unless @options[:quiet]
        validate(@erb_result, path)
        json = @pretty ?
          JSON.pretty_generate(JSON.parse(@erb_result)) :
          @erb_result
        File.open(path, 'w') {|f| f.write(output_json(json)) }
      end

      def validate(json, path)
        begin
          JSON.parse(json)
        rescue JSON::ParserError => e
          puts "Invalid json.  Output written to #{path} for debugging".colorize(:red)
          File.open(path, 'w') {|f| f.write(json) }
          exit 1
        end
      end

      def output_json(json)
        @options[:pretty] ? JSON.pretty_generate(JSON.parse(json)) : json
      end
    end
  end
end
