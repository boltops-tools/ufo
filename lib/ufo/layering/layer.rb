require "aws_data"

# Layers example
#
#     .ufo/vars.rb
#     .ufo/vars/base.rb
#     .ufo/vars/dev.rb
#     .ufo/vars/prod.rb
#     .ufo/vars/app1.rb
#     .ufo/vars/app1/base.rb
#     .ufo/vars/app1/dev.rb
#     .ufo/vars/app1/prod.rb
#
module Ufo::Layering
  class Layer
    extend Memoist
    include Ufo::Layering
    include Ufo::Utils::Logging
    include Ufo::Utils::Pretty

    def initialize(task_definition)
      @task_definition = task_definition
    end

    def paths
      # core = full_layers(".ufo/vars")
      # app = full_layers(".ufo/vars/#{Ufo.app}")

      core =     layer_levels(".ufo/vars")
      role =     layer_levels(".ufo/vars/#{@task_definition.role}")
      app =      layer_levels(".ufo/vars/#{Ufo.app}")
      app_role = layer_levels(".ufo/vars/#{Ufo.app}/#{@task_definition.role}")

      paths = core + role + app + app_role
      add_ext!(paths)
      paths.map! { |p| "#{Ufo.root}/#{p}" }
      show_layers(paths)
      paths
    end

    # adds prefix and to each layer pair that has base and Ufo.env. IE:
    #
    #    "#{prefix}/base"
    #    "#{prefix}/#{Ufo.env}"
    #
    def layer_levels(prefix=nil)
      levels = ["", "base", Ufo.env]
      levels << "#{Ufo.env}-#{Ufo.extra}" if Ufo.extra
      levels.map! do |i|
        # base layer has prefix of '', reject with blank so it doesnt produce '//'
        [prefix, i].reject(&:blank?).join('/')
      end
      levels.map! { |level| level.sub(/\/$/,'') } # strip trailing slash
      # levels.unshift(prefix) # unless prefix.blank? # IE: params/us-west-2.txt
      levels
    end

    # interface method
    def main_layers
      ['']
    end

    def add_ext!(paths)
      paths.map! do |path|
        path = path.sub(/\/$/,'') if path.ends_with?('/')
        "#{path}.rb"
      end
      paths
    end

    @@shown = false
    def show_layers(paths)
      return if @@shown
      logger.debug "Layers:"
      paths.each do |path|
        if ENV['UFO_LAYERS_ALL']
          logger.info "    #{pretty_path(path)}"
        elsif Ufo.config.layering.show
          logger.info "    #{pretty_path(path)}" if File.exist?(path)
        end
      end
      @@shown = true
    end
  end
end
