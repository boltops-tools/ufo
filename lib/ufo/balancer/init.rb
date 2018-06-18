module Ufo
  class Balancer::Init < Thor::Group
    include Thor::Actions
    include AwsService
    include NetworkSetting

    add_runtime_options! # force, pretend, quiet, skip options
      # https://github.com/erikhuda/thor/blob/master/lib/thor/actions.rb#L49

    # Interesting, when defining the options in this class it screws up the ufo balance -h menu
    Balancer.cli_options.each do |o|
      class_option *o
    end
    def self.source_paths
      [File.expand_path("../../../template/.ufo/.balancer", __FILE__)]
    end

    def set_network_options
      configure_network_settings
    end

    def starter_files
      directory ".", ".ufo/.balancer"
    end
  end
end
