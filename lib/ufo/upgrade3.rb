require 'fileutils'

module Ufo
  class Upgrade3
    def initialize(options)
      @options = options
    end

    def run
      if File.exist?("#{Ufo.root}/.ufo")
        puts "It looks like you already have a .ufo folder in your project. This is the new project structure so exiting without updating anything."
        return
      end

      if !File.exist?("#{Ufo.root}/ufo")
        puts "Could not find a ufo folder in your project. Maybe you want to run ufo init to initialize a new ufo project instead?"
        return
      end

      puts "Upgrading structure of your current project to the new ufo version 3 project structure"
      mv("ufo/settings.yml", "ufo/settings/base.yml")
      mv("ufo", ".ufo")
      puts "Upgrade complete."
    end

    def mv(src, dest)
      puts "mv #{src} #{dest}"
      FileUtils.mv(src, dest)
    end
  end
end
