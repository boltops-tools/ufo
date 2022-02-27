class Ufo::CLI
  class Base
    extend Memoist
    include Ufo::AwsServices
    include Ufo::Concerns
    include Ufo::Utils::Logging
    include Ufo::Utils::Pretty
    include Ufo::Utils::Sure

    attr_reader :task_definition
    def initialize(options={})
      @options = options
      @task_definition = Ufo::TaskDefinition.new(options)
      @stack_name = names.stack
      @cluster = names.cluster
    end
  end
end
