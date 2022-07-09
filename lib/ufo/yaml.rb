module Ufo
  class Yaml
    class << self
      def load(text)
        path = "#{Ufo.root}/.ufo/tmp/temp.yml"
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
