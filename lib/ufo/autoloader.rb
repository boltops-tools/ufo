require "zeitwerk"

module Ufo
  class Autoloader
    class Inflector < Zeitwerk::Inflector
      def camelize(basename, _abspath)
        map = { cli: "CLI", dsl: "DSL", version: "VERSION" }
        map[basename.to_sym] || super
      end
    end

    class << self
      def setup
        loader = Zeitwerk::Loader.new
        loader.inflector = Inflector.new
        loader.push_dir(File.dirname(__dir__)) # lib
        loader.setup
      end
    end
  end
end
