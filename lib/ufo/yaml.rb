module Ufo
  class Yaml
    class << self
      def load(text)
        path = "/tmp/ufo/temp.yml"
        FileUtils.mkdir_p(File.dirname(path))
        IO.write(path, text)
        Validator.new(path).validate!
        Loader.new(text).load
      end

      def validate!(path)
        Validator.new(path).validate!
      end
    end
  end
end
