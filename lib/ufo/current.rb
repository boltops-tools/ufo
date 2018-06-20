require 'fileutils'

module Ufo
  class Current
    def initialize(service=nil, options={})
      Ufo.check_ufo_project!
      @service = service
      @options = options
      @file = ".ufo/current"
      @path = "#{Ufo.root}/#{@file}"
    end

    def run
      @options[:unset] ? unset : set
    end

    def unset
      FileUtils.rm_f(@path)
      puts "Current service is unset. Removed #{@file}"
    end

    def set
      if @service
        IO.write(@path, @service)
        puts "Current service saved as #{@service} in #{@file}"
      else
        if service
          puts "Current service is set to: #{service}"
        else
          puts "No current service set."
        end
      end
    end

    def service
      if File.exist?(@path)
        current = IO.read(@path).strip
        return current unless current.empty?
      end
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

      puts <<-EOL
ERROR: service must be specified at the cli:
    ufo #{ARGV.first} SERVICE
Or you can set a current service must be set with:
    ufo current SERVICE
EOL
      exit 1
      # if want to display full help menu:
      # Ufo::CLI.start(ARGV + ["-h"])
    end
  end
end
