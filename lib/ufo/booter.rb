module Ufo
  module Booter
    def boot
      run_hooks
    end

    # Special boot hooks run super early.
    # Useful for setting env vars and other early things.
    #
    #    .ufo/boot.rb
    #    .ufo/boot/dev.rb
    #
    def run_hooks
      run_hook
      run_hook(Ufo.env)
      Ufo::Config::Inits.run_all
    end

    def run_hook(env=nil)
      name = env ? "boot/#{env}" : "boot"
      path = "#{Ufo.root}/.ufo/config/#{name}.rb" # IE: .ufo/boot/dev.rb
      require path if File.exist?(path)
    end

    extend self
  end
end
