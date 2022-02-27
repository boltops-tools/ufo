class Ufo::TaskDefinition::Erb
  class Base < Ufo::CLI::Base
    def initialize(options={})
      super
      @path = options[:path]
      @task_definition = options[:task_definition]
    end

    def print_code(text)
      lines = text.split("\n")
      lpad = lines.size.to_s.size
      lines.each_with_index do |line,n|
        printf("%#{lpad}d %s\n", n+1, line)
      end
      nil
    end
  end
end
