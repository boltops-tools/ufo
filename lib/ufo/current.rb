require 'fileutils'

module Ufo
  class Current
    def initialize(service=nil, options={})
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

    def self.service
      Current.new.service
    end
  end
end
