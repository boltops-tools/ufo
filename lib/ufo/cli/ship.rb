class Ufo::CLI
  class Ship < Base
    include Ufo::Concerns

    def run
      are_you_sure?
      build_task_definition
      deploy.run
      ps.run
    end

    def build_task_definition
      return if @options[:rollback]
      build.docker
      build.task_definition
    end

  private
    def are_you_sure?
      message = "Will deploy stack #{@stack_name.color(:green)}"
      if @options[:yes]
        logger.info message
      else
        sure?(message)
      end
    end
  end
end
