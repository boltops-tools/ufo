class Ufo::Stack
  class CustomProperties
    include Ufo::Settings

    def initialize(template, stack_name)
      @template, @stack_name = template, stack_name
    end

    def apply
      customizations = camelize(cfn)
      @template["Resources"].each do |logical_id, attrs|
        custom_props = customizations[logical_id]
        next unless custom_props
        attrs["Properties"].deeper_merge!(custom_props, {overwrite_arrays: true})
      end

      substitute_variables!(@template["Resources"])
      @template
    end

    # Keep backward compatiablity but encouraging CamelCase now because in the ufo init generator
    # the .ufo/settings/cfn/default.yml is now CamelCase
    def camelize(properties)
      if ENV['UFO_CAMELIZE'] == '0' || settings[:auto_camelize] == false # provide a way to quickly test full camelize disable
        return properties.deep_stringify_keys
      end

      # transform keys: camelize
      properties.deep_stringify_keys.deep_transform_keys do |key|
        if key == key.upcase # trying to generalize special rule for dns.TTL
          key # leave key alone if key is already in all upcase
        else
          key.camelize
        end
      end
    end

    # Substitute special variables that cannot be baked into the template
    # because they are dynamically assigned. Only one special variable:
    #
    #   {stack_name}
    def substitute_variables!(properties)
      # transform values and substitute for special values
      # https://stackoverflow.com/questions/34595142/process-nested-hash-to-convert-all-values-to-strings
      #
      # Examples:
      #   "{stack_name}.stag.boltops.com." => development-demo-web.stag.boltops.com.
      #   "{stack_name}.stag.boltops.com." => dev-demo-web-2.stag.boltops.com.
      properties.deep_merge(properties) do |_,_,v|
        if v.is_a?(String)
          v.sub!('{stack_name}', @stack_name) # need shebang, updating in-place
        else
          v
        end
      end
      properties
    end
  end
end
