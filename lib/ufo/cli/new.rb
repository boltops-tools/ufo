class Ufo::CLI
  class New < Ufo::Command
    desc "boot_hook", "Generate boot_hook file"
    long_desc Help.text("new/boot_hook")
    BootHook.cli_options.each do |args|
      option(*args)
    end
    register(BootHook, "boot_hook", "boot_hook", "Generate boot_hook file")

    desc "helper", "Generate helper file"
    long_desc Help.text("new/helper")
    Helper.cli_options.each do |args|
      option(*args)
    end
    register(Helper, "helper", "helper", "Generate helper file")
  end
end
