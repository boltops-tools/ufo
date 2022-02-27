module Ufo::Docker
  class Compiler
    def initialize(dockerfile)
      @dockerfile = dockerfile
      @erb_file = "#{dockerfile}.erb"
    end

    def compile
      return unless File.exist?(@erb_file)

      puts "Compiled #{File.basename(@erb_file).color(:green)} to #{File.basename(@dockerfile).color(:green)}"
      path = "#{Ufo.root}/.ufo/state/data.yml"
      vars = YAML.load_file(path)[Ufo.env] if File.exist?(path)
      vars ||= {}
      result = RenderMePretty.result(@erb_file, vars)
      comment =<<~EOL.chop # remove the trailing newline
        # IMPORTANT: This file was generated from #{File.basename(@erb_file)} as a part of running:
        #
        #     ufo ship
        #
        # To update the FROM statement with the latest base docker image use:
        #
        #    ufo docker base
        #
      EOL
      result = "#{comment}\n#{result}"
      IO.write(@dockerfile, result)
    end
  end
end
