class Ufo::CLI
  class Status < Base
    def run
      stack = Ufo::Cfn::Stack.new(@options)
      stack.status.wait
    end
  end
end
