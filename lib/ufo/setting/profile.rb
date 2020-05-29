class Ufo::Setting
  class Profile
    extend Memoist

    def initialize(type, profile=nil)
      @type = type.to_s # cfn or network
      @profile = profile
    end

    def data
      names = [
        @profile, # user specified
        Ufo.env, # conventional based on env
        "default", # fallback to default
      ].compact.uniq
      paths = names.map { |name| "#{Ufo.root}/.ufo/settings/#{@type}/#{name}.yml" }
      found = paths.find { |p| File.exist?(p) }
      unless found
        puts "#{@type.camelize} profile not found. Please double check that it exists. Checked paths: #{paths}"
        exit 1
      end

      text = RenderMePretty.result(found)
      YAML.load(text).deep_symbolize_keys
    end
    memoize :data
  end
end
