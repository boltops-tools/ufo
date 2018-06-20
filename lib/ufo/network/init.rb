module Ufo
  class Network::Init < Thor::Group
    include Thor::Actions
    include Network::Helper

    add_runtime_options! # force, pretend, quiet, skip options
      # https://github.com/erikhuda/thor/blob/master/lib/thor/actions.rb#L49

    # Interesting, when defining the options in this class it screws up the ufo balance -h menu
    Network.cli_options.each do |o|
      class_option *o
    end
    def self.source_paths
      [File.expand_path("../../../template/.ufo/settings/network", __FILE__)]
    end

    def set_network_options
      configure_network_settings
    end

    def starter_files
      profile_name = @options[:profile_name] || "default"
      template "default.yml", ".ufo/settings/network/#{profile_name}.yml"
    end
  end
end
