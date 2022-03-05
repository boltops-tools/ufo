class Ufo::CLI
  class Build < Base
    def build
      docker
      task_definition
      Ufo::Cfn::Stack.new(@options).build
    end
    alias_method :all, :build

    def for_deploy
      docker
      task_definition
    end

    def task_definition
      Ufo::TaskDefinition::Builder.new(@options).build
    end

    def docker
      return if @options[:docker] == false
      # The config.docker.quiet only effects: ufo ship, not ufo docker build
      quiet = Ufo.config.ship.docker.quiet
      o = @options.dup.merge(quiet: quiet)
      builder = Ufo::Docker::Builder.new(o)
      builder.build
      pusher = Ufo::Docker::Pusher.new(nil, o)
      pusher.push
    end
  end
end
