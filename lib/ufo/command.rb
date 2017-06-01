module Ufo
  class Command < Thor
    class << self
      def dispatch(m, args, options, config)
        # Allow calling for help via:
        #   ufo docker help
        #   ufo docker -h
        #   ufo docker --help
        #   ufo docker -D
        #
        # as well thor's nomral setting as
        #
        #   ufo help docker
        help_flags = Thor::HELP_MAPPINGS + ["help"]
        if args.length > 1 && !(args & help_flags).empty?
          args -= help_flags
          args.insert(-2, "help")
        end
        super
      end
    end
  end
end
