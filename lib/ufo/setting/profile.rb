class Ufo::Setting
  class Profile
    extend Memoist

    def initialize(type, profile='default')
      @type = type.to_s # cfn or network
      @profile = profile
    end

    def data
      path = "#{Ufo.root}/.ufo/settings/#{@type}/#{@profile}.yml"
      unless File.exist?(path)
        puts "#{@type.camelize} profile #{path} not found. Please double check that it exists."
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
