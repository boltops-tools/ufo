require "thor"

# Override thor's long_desc identation behavior
# https://github.com/erikhuda/thor/issues/398
class Thor
  module Shell
    class Basic
      def print_wrapped(message, options = {})
        message = "\n#{message}" unless message[0] == "\n"
        stdout.puts message
      end
    end
  end

  module Util
    # Hack to fix issue when -h produces extra ufo command in help.  IE:
    #
    # $ bundle exec ufo blueprint -h
    # Commands:
    #   ...
    #   ufo ufo:blueprint:new BLUEPRINT_NAME  <= weird
    #
    # It looks like thor_classes_in is only used to generate the help menu.
    #
    def self.thor_classes_in(*)
      []
    end
  end
end

module Ufo
  class Command < Thor
    class << self
      include Ufo::Utils::Logging

      def dispatch(m, args, options, config)
        # Old note: Configuring the DslEvalulator requires Ufo.root and Ufo.logger which
        # loads Ufo.config and Ufo::Config#load_project_config
        # This requires Ufo.role.
        # So we set Ufo.role before triggering Ufo.config loading
        check_project!(args)
        # Special case for `ufo central` commands.
        # Dont want to call configure_dsl_evaluator
        # and trigger loading of config => .ufo/config.rb
        # Also, using ARGV instead of args because args is called by thor in multiple passes
        # For `ufo central update`:
        # * 1st pass: "central"
        # * 2nd pass: "update"
        configure_dsl_evaluator unless ARGV[0] == "central"

        # Allow calling for help via:
        #   ufo command help
        #   ufo command -h
        #   ufo command --help
        #   ufo command -D
        #
        # as well thor's normal way:
        #
        #   ufo help command
        if args.length > 1 && !(args & help_flags).empty?
          args -= help_flags
          args.insert(-2, "help")
        end

        #   ufo version
        #   ufo --version
        #   ufo -v
        version_flags = ["--version", "-v"]
        if args.length == 1 && !(args & version_flags).empty?
          args = ["version"]
        end

        super
      end

      # Uses Ufo.logger and Ufo.root which loads Ufo.config.
      # See comment where configure_dsl_evaluator is used about Ufo.role
      def configure_dsl_evaluator
        DslEvaluator.configure do |config|
          config.backtrace.select_pattern = Ufo.root.to_s
          config.logger = Ufo.logger
          config.on_exception = :exit
          config.root = Ufo.root
        end
      end

      def help_flags
        Thor::HELP_MAPPINGS + ["help"]
      end
      private :help_flags

      def subcommand?
        !!caller.detect { |l| l.include?('in subcommand') }
      end

      def check_project!(args)
        command_name = args.first
        return if subcommand?
        return if command_name.nil?
        return if help_flags.include?(args.last) # IE: -h help
        return if %w[-h -v --version central init version].include?(command_name)
        return if File.exist?("#{Ufo.root}/.ufo")

        logger.error "ERROR: It doesnt look like this is a ufo project. Are you sure you are in a ufo project?".color(:red)
        ENV['UFO_TEST'] ? raise : exit(1)
      end

      # Override command_help to include the description at the top of the
      # long_description.
      def command_help(shell, command_name)
        meth = normalize_command_name(command_name)
        command = all_commands[meth]
        alter_command_description(command)
        super
      end

      def alter_command_description(command)
        return unless command

        # Add description to beginning of long_description
        long_desc = if command.long_description
            "#{command.description}\n\n#{command.long_description}"
          else
            command.description
          end

        # add reference url to end of the long_description
        unless website.empty?
          full_command = [command.ancestor_name, command.name].compact.join('-')
          url = "#{website}/reference/ufo-#{full_command}"
          long_desc += "\n\nHelp also available at: #{url}"
        end

        command.long_description = long_desc
      end
      private :alter_command_description

      # meant to be overriden
      def website
        "http://ufoships.com"
      end

      # https://github.com/erikhuda/thor/issues/244
      # Deprecation warning: Thor exit with status 0 on errors. To keep this behavior, you must define `exit_on_failure?` in `Lono::CLI`
      # You can silence deprecations warning by setting the environment variable THOR_SILENCE_DEPRECATION.
      def exit_on_failure?
        true
      end
    end
  end
end
