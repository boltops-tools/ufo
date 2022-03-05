class Ufo::Cfn::Stack
  class Template < Ufo::Cfn::Base
    def body
      builder = Builder.new(@options)
      builder.build
    end
  end
end
