class Ufo::CLI
  class Opts
    def initialize(cli)
      @cli = cli
    end

    def yes
      with_cli_scope do
        option :yes, aliases: :y, type: :boolean, desc: "Bypass are you sure prompt"
      end
    end

    def docker
      with_cli_scope do
        option :docker, type: :boolean, default: true, desc: "Skip docker build"
      end
    end

    # Based on https://github.com/rails/thor/blob/ab3b5be455791f4efb79f0efb4f88cc6b59c8ccf/lib/thor/actions.rb#L48
    def runtime_options
      with_cli_scope do
        option :force, :type => :boolean, :aliases => "-f", :group => :runtime,
                             :desc => "Overwrite files that already exist"

        option :skip, :type => :boolean, :aliases => "-s", :group => :runtime,
                            :desc => "Skip files that already exist"
      end
    end

  private
    def with_cli_scope(&block)
      @cli.instance_eval(&block)
    end
  end
end
