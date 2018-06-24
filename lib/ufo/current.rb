require 'fileutils'
require 'yaml'

module Ufo
  class Current
    def initialize(options={})
      Ufo.check_ufo_project!
      @options = options
      @file = ".ufo/current"
      @path = "#{Ufo.root}/#{@file}"
    end

    def run
      @options[:rm] ? rm : set
    end

    def rm
      FileUtils.rm_f(@path)
      puts "Current settings have been removed. Removed #{@file}"
    end

    def set
      if @options.empty?
        show
      else
        d = data # assign data to d to create local variable for merge to work
        d = d.merge(@options).delete_if do |_,v|
          v&.empty? || v == ['']
        end
        text = YAML.dump(d)
        IO.write(@path, text)
        puts "Current settings saved in .ufo/current"
        show
      end
    end

    def show
      data.each do |key, value|
        puts "Current #{key}: #{value}"
      end
    end

    def data
      YAML.load(IO.read(@path)) rescue {}
    end

    def env_extra
      current = data["env_extra"]
      return current unless current&.empty?
    end

    def self.env_extra
      Current.new.env_extra
    end

    def services
      return data["services"] || []
    end

    # reads services, returns [] if not set
    def self.services
      Current.new.services
    end

    def service
      current = data["service"]
      return current unless current&.empty?
    end

    # reads service, returns nil if not set
    def self.service
      Current.new.service
    end

    # reads service, will exit if current service not set
    def self.service!(service=:current)
      return service if service != :current

      service = Current.service
      return service if service

      puts "ERROR: service must be specified.".colorize(:red)
      puts <<-EOL
Example:
    ufo #{ARGV.first} SERVICE
You can also set a current service to be remembered with:
    ufo current SERVICE
EOL
      exit 1
      # if want to display full help menu:
      # Ufo::CLI.start(ARGV + ["-h"])
    end
  end
end
