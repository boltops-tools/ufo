class Ufo::Docker
  class Compiler
    def initialize(dockerfile)
      @dockerfile = dockerfile
      @erb_file = "#{dockerfile}.erb"
    end

    def compile
      return unless File.exist?(@erb_file)

      puts "Compiled #{File.basename(@erb_file).color(:green)} to #{File.basename(@dockerfile).color(:green)}"
      path = "#{Ufo.root}/.ufo/settings/dockerfile_variables.yml"
      vars = YAML.load_file(path)[Ufo.env] if File.exist?(path)
      vars ||= {}
      result = RenderMePretty.result(@erb_file, vars)
      comment = "# Note this file was generated from #{File.basename(@erb_file)} as a part of running ufo ship"
      result = "#{comment}\n#{result}"
      IO.write(@dockerfile, result)
    end
  end
end
