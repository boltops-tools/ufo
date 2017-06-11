module Ufo
  class Tasks < Command
    autoload :Help, 'ufo/tasks/help'

    desc "build", "builds task definitions"
    long_desc Help.build
    option :pretty, type: :boolean, default: true, desc: "Pretty format the json for the task definitions"
    def build
      TasksBuilder.new(options).build
    end

    desc "register", "register all built task definitions in ufo/output"
    long_desc Help.register
    def register
      TasksRegister.register(:all, options)
    end
  end

end
