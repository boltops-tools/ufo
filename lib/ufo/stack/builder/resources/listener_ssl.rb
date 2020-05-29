class Ufo::Stack::Builder::Resources
  class ListenerSsl < Listener
    def build
      return unless @create_listener_ssl
      super
    end

    def protocol
      @default_listener_ssl_protocol
    end

    # nil on purpose
    def port
    end
  end
end
