require 'yaml'

module Ufo
  class Param
    extend Memoist

    def initialize
      @params_path = "#{Ufo.root}/.ufo/params.yml"
    end

    def data
      upgrade_message!

      result = RenderMePretty.result(@params_path, context: template_scope)
      YAML.load(result)
    end
    memoize :data

    def template_scope
      @template_scope ||= Ufo::TemplateScope.new(Ufo::DSL::Helper.new, nil)
    end

    # Ufo version 3.3 to 3.4 added a concept of a .ufo/params.yml file to support
    # fargate: https://github.com/tongueroo/ufo/pull/31
    #
    # Warn user and tell them to run the `ufo upgrade3_3_to_3_4` command to upgrade.
    def upgrade_message!
      return if File.exist?(@params_path)

      puts "ERROR: Your project is missing the .ufo/params.yml.".colorize(:red)
      puts "This was added in ufo version 3.4 for Fargate support: https://github.com/tongueroo/ufo/pull/31"
      puts "You can find more info about the params file here: http://ufoships.com/docs/params/"
      puts "To upgrade run:"
      puts "  ufo upgrade3_3_to_3_4"
      exit 1
    end
  end
end
