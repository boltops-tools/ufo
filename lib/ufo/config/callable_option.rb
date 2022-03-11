# Class represents a config option that is possibly callable. Examples:
#
#    config.names.stack
#    config.names.task_definition
#
# Abstraction is definitely obtuse. Using it to get rid of duplication.
#
class Ufo::Config
  class CallableOption
    include Ufo::Utils::Logging

    def initialize(options={})
      @options = options
      # Example:
      # config_name:  names.stack
      # config_value: Ufo.config.names.stack
      # args:         [self] # passed to object.call
      @config_name = options[:config_name]
      @config_value = options[:config_value] || inferred_config_value
      @config_name = "config.#{@config_name}" unless @config_name.include?("config.")
      @passed_args = options[:passed_args]
    end

    def inferred_config_value
      args = @options[:config_name].split('.').map(&:to_sym) # @options before @config_name is adjust to have full config name
      Ufo.config.dig(*args)
    end

    # Returns either an Array or nil
    def object
      case @config_value
      when nil
        return nil
      when Array, String
        return @config_value
      when -> (c) { c.respond_to?(:public_instance_methods) && c.public_instance_methods.include?(:call) }
        object= @config_value.new
      when -> (c) { c.respond_to?(:call) }
        object = @config_value
      else
        raise "Invalid option for #{@config_name}"
      end

      if object
        result = @passed_args.empty? ? object.call : object.call(*@passed_args)
        valid_classes = [Array, String, NilClass]
        valid_classes_help = valid_classes
        valid_classes_help[-1] = "or #{valid_classes_help[-1]}"
        valid_classes_help = valid_classes.join(', ')
        unless valid_classes.include?(result.class)
          message = "ERROR: The #{@config_name} needs to return an #{valid_classes_help}"
          logger.info message.color(:red)
          logger.info <<~EOL
            The #{@config_name} when assigned a class, object, or proc must implement
            The call method and return an #{valid_classes_help}.
            The current return value is a #{result.class}
          EOL
          exit 1
        end
      end
      result
    end
  end
end
