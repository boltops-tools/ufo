module Ufo::Utils
  class Squeezer
    def initialize(data)
      @data = data
    end

    def squeeze(new_data=nil)
      data = new_data.nil? ? @data : new_data

      case data
      when Array
        # .compact prevents infinite loop when data = [nil] on accident
        # IE: config.elb.ssl.certificates = acm_cert("domain.not.found")
        data.compact.map! { |v| squeeze(v) }
      when Hash
        data.each_with_object({}) do |(k,v), squeezed|
          # only remove nil and empty Array values within Hash structures
          squeezed[k] = squeeze(v) unless v.nil? # || v.is_a?(Array) && v.empty?
          squeezed
        end
      else
        data # do not transform
      end
    end
  end
end
