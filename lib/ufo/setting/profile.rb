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
        "base", # finally fallback to base
      ].compact.uniq
      paths = names.map { |name| "#{Ufo.root}/.ufo/settings/#{@type}/#{name}.yml" }
      found = paths.find { |p| File.exist?(p) }
      unless found
        puts "#{@type.camelize} profile not found. Please double check that it exists. Checked paths: #{paths}"
        exit 1
      end

      text = RenderMePretty.result(found)
      specific_data = YAML.load(text).deep_symbolize_keys

      base = "#{Ufo.root}/.ufo/settings/#{@type}/base.yml"
      base_data = if File.exist?(base)
                    text = RenderMePretty.result(base)
                    YAML.load(text).deep_symbolize_keys
                  else
                    {}
                  end

      base_data.deep_merge(specific_data)
    end
    memoize :data
  end
end
