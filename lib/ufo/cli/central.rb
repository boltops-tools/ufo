class Ufo::CLI
  class Central < Ufo::Command
    opts = Opts.new(self)

    desc "update", "update .ufo from central repo"
    long_desc Help.text("central/update")
    opts.yes
    def update
      Update.new(options).run
    end

    desc "clean", "remove ~/.ufo/central"
    long_desc Help.text("central/clean")
    opts.yes
    def clean
      Clean.new(options).run
    end
  end
end
