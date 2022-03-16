module Ufo::Docker
  class State
    extend Memoist

    def initialize(options={})
      @options = options
    end

    def update
      storage.update
    end

    def read
      storage.read
    end

  private
    # Examples:
    #   File.new(@docker_image, @options)
    #   S3.new(@docker_image, @options)
    def storage
      storage = Ufo.config.state.storage
      class_name = "Ufo::Docker::State::#{storage.camelize}"
      klass = class_name.constantize
      klass.new(@options)
    end
    memoize :storage
  end
end
