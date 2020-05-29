class Ufo::Stack
  class TemplateBody
    def initialize(context)
      @context = context
    end

    def build
      builder = Builder.new(@context)
      builder.build
    end
  end
end

