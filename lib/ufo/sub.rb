module Ufo
  class Sub < Command

    desc "goodbye NAME", "say goodbye to NAME"
    long_desc Help.text("sub:goodbye")
    option :from, desc: "from person"
    def goodbye(name="you")
      puts "from: #{options[:from]}" if options[:from]
      puts "Goodbye #{name}"
    end
  end
end
