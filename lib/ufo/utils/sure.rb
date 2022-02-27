module Ufo::Utils
  module Sure
    def sure?(message=nil)
      confirm = 'Are you sure?'
      if @options[:yes]
        yes = 'y'
      else
        out = if message
                "#{message}\n#{confirm} (y/N) "
              else
                "#{confirm} (y/N) "
              end
        print out
        yes = $stdin.gets
      end

      unless yes =~ /^y/
        puts "Whew! Exiting."
        exit 0
      end
    end
  end
end
