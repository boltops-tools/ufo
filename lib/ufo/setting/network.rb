class Ufo::Setting
  class Network
    extend Memoist

    def initialize(profile='default')
      @profile = profile
    end

    def data
      path = "#{Ufo.root}/.ufo/settings/network/#{@profile}.yml"
      unless File.exist?(path)
        puts "Network profile #{path} not found. Please double check that it exists."
        exit 1
      end

      text = RenderMePretty.result(path)
      # puts "text:".colorize(:cyan)
      # puts text
      YAML.load(text).deep_symbolize_keys
    end
    memoize :data
  end
end
