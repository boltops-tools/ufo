# Some limitations:
#
# * Only parsing one file: .ufo/config.rb
# * If user is using Ruby code that cannot be parse will fallback to default
#
# Think it's worth it so user only has to configure
#
#     config.layering.show = true
#
class Ufo::Config
  class Parse
    def for(config, type: :boolean)
      lines = IO.readlines("#{Ufo.root}/.ufo/config.rb")
      config_line = lines.find do |l|
        # IE: Regexp.new("config\.layering.show.*=")
        regexp = Regexp.new("config\.#{config}.*=")
        l =~ regexp && l !~ /^\s+#/
      end
      return false unless config_line # default is false
      config_value = config_line.gsub(/.*=/,'').strip.gsub(/["']/,'')
      case type
      when :array
        eval(config_value) # IE: '["a"]' => ["a"]
      when :boolean
        config_value != "false" && config_value != "nil"
      when :string
        config_value.sub(/\s+#.*/,'') # remove trailing comment
      else
        raise "Type #{type.inspect} not supported"
      end
    rescue Exception => e
      # if ENV['UFO_DEBUG']
        puts "#{e.class} #{e.message}".color(:yellow)
        puts "WARN: Unable to parse for config.layering.show".color(:yellow)
        puts "Using default: config.layering.show = false"
      # end
      false
    end
  end
end

