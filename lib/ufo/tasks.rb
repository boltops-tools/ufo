module Ufo
  class Tasks < Command
    desc "build", "Build task definitions."
    long_desc Help.text("tasks:build")
    option :image_override, desc: "Override image in task definition for quick testing"
    def build
      Tasks::Builder.new(options).build
    end

    desc "register", "Register all built task definitions in `ufo/output` folder."
    long_desc Help.text("tasks:register")
    def register
      Tasks::Register.register(:all, options)
    end
  end
end
