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
      core = full_layers(".ufo/vars")
      app = full_layers(".ufo/vars/#{Ufo.app}")
      paths = core + app
      add_ext!(paths)
      paths.map! { |p| "#{Ufo.root}/#{p}" }
      show_layers(paths)
      paths
    end

    def full_layering
      # layers defined in Lono::Layering module
      all = layers.map { |layer| layer.sub(/\/$/,'') } # strip trailing slash
      all.inject([]) do |sum, layer|
        sum += layer_levels(layer) unless layer.nil?
        sum
      end
    end

    # interface method
    def main_layers
      ['']
    end

    # adds prefix and to each layer pair that has base and Ufo.env. IE:
    #
    #    "#{prefix}/base"
    #    "#{prefix}/#{Ufo.env}"
    #
    def layer_levels(prefix=nil)
      levels = ["base", Ufo.env]
      levels.map! do |i|
        # base layer has prefix of '', reject with blank so it doesnt produce '//'
        [prefix, i].reject(&:blank?).join('/')
      end
      levels.unshift(prefix) # unless prefix.blank? # IE: params/us-west-2.txt
      levels
    end

    def add_ext!(paths)
      ext = "rb"
      paths.map! do |path|
        path = path.sub(/\/$/,'') if path.ends_with?('/')
        "#{path}.rb"
      end
      paths
    end

    def full_layers(dir)
      layers = full_layering.map do |layer|
        "#{dir}/#{layer}"
      end
      role_layers = full_layering.map do |layer|
        "#{dir}/#{@task_definition.role}/#{layer}" # Note: layer can be '' will clean up
      end
      layers += role_layers
      layers.map { |l| l.gsub('//','/') } # cleanup // if layer is ''
    end

    @@shown_layers = false
    def show_layers(paths)
      return if @@shown_layers
      logger.info "Vars Layers:" if ENV['UFO_SHOW_ALL_LAYERS']
      paths.each do |path|
        show_layer = File.exist?(path) && logger.level <= Logger::DEBUG
        logger.info "    #{pretty_path(path)}" if show_layer || ENV['UFO_SHOW_ALL_LAYERS']
      end
      @@shown_layers = true
    end
  end
end
