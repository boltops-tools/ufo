module Ufo
  class TemplateScope
    extend Memoist

    attr_reader :helper
    attr_reader :task_definition_name
    def initialize(helper=nil, task_definition_name=nil)
      @helper = helper
      @task_definition_name = task_definition_name # only available from task_definition
        # not available from params
      load_variables_file("base")
      load_variables_file(Ufo.env)
    end

    # Load the variables defined in ufo/variables/* to make available in the
    # template blocks in ufo/templates/*.
    #
    # Example:
    #
    #   `ufo/variables/base.rb`:
    #     @name = "docker-process-name"
    #     @image = "docker-image-name"
    #
    #   `ufo/templates/main.json.erb`:
    #   {
    #     "containerDefinitions": [
    #       {
    #          "name": "<%= @name %>",
    #          "image": "<%= @image %>",
    #      ....
    #   }
    #
    # NOTE: Only able to make instance variables avaialble with instance_eval
    #   Wasnt able to make local variables available.
    def load_variables_file(filename)
      path = "#{Ufo.root}/.ufo/variables/#{filename}.rb"
      instance_eval(IO.read(path), path) if File.exist?(path)
    end

    # Add additional instance variables to template_scope
    def assign_instance_variables(vars)
      vars.each do |k,v|
        instance_variable_set("@#{k}".to_sym, v)
      end
    end

    def network
      Ufo::Setting::Profile.new(:network, settings[:network_profile]).data
    end
    memoize :network

    def cfn
      Ufo::Setting::Profile.new(:cfn, settings[:cfn_profile]).data
    end
    memoize :cfn

    def settings
      Ufo.settings
    end

    def custom_properties(resource)
      resource = resource.to_s.underscore
      properties = cfn[resource.to_sym]
      return unless properties

      # transform keys: camelize
      properties = properties.deep_stringify_keys.deep_transform_keys do |key|
        if key == key.upcase # trying to generalize special rule for dns.TTL
          key # leave key alone if key is already in all upcase
        else
          key.camelize
        end
      end

      substitute_variables!(properties)

      yaml = YAML.dump(properties)
      # add spaces in front on each line
      yaml.split("\n")[1..-1].map do |line|
        "      #{line}"
      end.join("\n") + "\n"
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
      #   "{stack_name}.stag.boltops.com." => development-hi-web.stag.boltops.com.
      #   "{stack_name}.stag.boltops.com." => dev-hi-web-2.stag.boltops.com.
      properties.deep_merge(properties) do |_,_,v|
        if v.is_a?(String)
          v.sub!('{stack_name}', @stack_name) # unsure why need shebang, but it works
        else
          v
        end
      end
      properties
    end

    def default_target_group_protocol
      default_elb_protocol
    end

    def default_elb_protocol
      @elb_type == "application" ? "HTTP" : "TCP"
    end

    def pretty_name?
      # env variable takes highest precedence
      if ENV["STATIC_NAME"]
        ENV["STATIC_NAME"] != "0"
      else
        settings[:pretty_name]
      end
    end
  end
end
