require 'logger'

module Ufo
  class Logger < ::Logger
    def initialize(*args)
      super
      self.formatter = Formatter.new
      self.level = ENV['UFO_LOG_LEVEL'] || :info # note: only respected when config.logger not set in config/app.rb
    end

    def format_message(severity, datetime, progname, msg)
      line = if @logdev.dev == $stdout || @logdev.dev == $stderr || @logdev.dev.is_a?(StringIO)
        msg # super simple format if stdout
      else
        super # use the configured formatter
      end
      line =~ /\n$/ ? line : "#{line}\n"
    end

    # Used to allow output to always go to stdout
    def stdout(msg, newline: true)
      if newline
        puts msg
      else
        print msg
      end
    end

    public :print
    public :printf
  end
end
