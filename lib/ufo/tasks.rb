module Ufo
  class Tasks < Command
    autoload :Builder, 'ufo/tasks/builder'
    autoload :Register, 'ufo/tasks/register'

    desc "build", "Build task definitions."
    long_desc Help.text("tasks:build")
    option :pretty, type: :boolean, default: true, desc: "Pretty format the json for the task definitions"
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
