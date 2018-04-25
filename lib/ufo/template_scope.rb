module Ufo
  class TemplateScope
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

    def assign_instance_variables
      # copy over the instance variables to make available in RenderMePretty's scope
      hash = {}
      instance_variables.each do |var|
        key = var.to_s.sub('@','') # rid of the leading @
        hash[key.to_sym] = instance_variable_get(var)
      end
      hash
    end
  end
end
