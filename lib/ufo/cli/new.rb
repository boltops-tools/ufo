class Ufo::CLI
  class New < Ufo::Command
    desc "helper", "Generate helper file"
    long_desc Help.text("new/helper")
    Helper.cli_options.each do |args|
      option(*args)
    end
    register(Helper, "helper", "helper", "Generate helper file")
  end
end
