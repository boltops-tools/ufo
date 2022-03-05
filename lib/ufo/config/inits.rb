class Ufo::Config
  class Inits
    class << self
      include DslEvaluator

      def run_all
        Dir.glob("#{Ufo.root}/.ufo/config/inits/*.rb").each do |path|
          evaluate_file(path)
        end
      end
    end
  end
end
