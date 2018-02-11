require 'fileutils'
require 'colorize'
require 'thor'

module Ufo
  class Sequence < Thor::Group
    include Thor::Actions

    def self.source_root
      File.expand_path("../../template", __FILE__)
    end

  private
    def confirm_cli_project
      cli_project = File.exist?("#{project_name}/config/application.rb")
      unless cli_project
        puts "It does not look like the repo #{options[:repo]} is a cli project. Maybe double check that it is?  Exited.".colorize(:red)
        exit 1
      end
    end

    def copy_project
      puts "Creating new project called #{project_name}."
      directory ".", project_name
    end
  end
end
