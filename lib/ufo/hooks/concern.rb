module Ufo::Hooks
  module Concern
    # options example: {name: "build", file: "docker.rb"}
    def run_hooks(options={}, &block)
      hooks = Ufo::Hooks::Builder.new(options)
      hooks.build # build hooks
      hooks.run_hooks(&block)
    end
  end
end
