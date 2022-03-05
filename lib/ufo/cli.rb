require 'thor'
require 'ufo/command'

module Ufo
  class CLI < Command
    include Help
    opts = Opts.new(self)

    desc "central SUBCOMMAND", "central subcommands"
    long_desc Help.text(:central)
    subcommand "central", Central

    desc "docker SUBCOMMAND", "docker subcommands"
    long_desc Help.text(:docker)
    subcommand "docker", Docker

    desc "new SUBCOMMAND", "new subcommands"
    long_desc Help.text(:new)
    subcommand "new", New

    desc "build", "Build docker image, task definition, cloudformation template"
    long_desc Help.text(:build)
    opts.docker
    def build
      Build.new(options).build
    end

    desc "cancel", "Cancel creation or update of the ECS service."
    long_desc Help.text(:cancel)
    option :yes, aliases: :y, type: :boolean, desc: "By pass are you sure prompt."
    def cancel
      Cancel.new(options).run
    end

    desc "clean", "Removes `.ufo/output` folders"
    opts.yes
    def clean
      Clean.new(options).run
    end

    desc "destroy", "Destroy the ECS service."
    long_desc Help.text(:destroy)
    option :yes, aliases: :y, type: :boolean, desc: "By pass are you sure prompt."
    option :wait, type: :boolean, desc: "Wait for completion", default: true
    def destroy
      Destroy.new(options).run
    end

    desc "exec", "Exec into container"
    long_desc Help.text(:exec)
    option :container, desc: "Container name to exec into. Default to role or first found"
    option :command, aliases: :c, desc: "Command to run. Default is configured config.exec.command option"
    def exec
      Exec.new(options).run
    end

    long_desc Help.text("init")
    New::Init.options.each { |args| option(*args) }
    register(New::Init, "init", "init", "Generate starter .ufo structure")

    desc "logs", "Prints out logs"
    long_desc Help.text(:logs)
    option :follow, default: true, type: :boolean, desc: " Whether to continuously poll for new logs. To exit from this mode, use Control-C."
    option :since, desc: "From what time to begin displaying logs.  By default, logs will be displayed starting from 1 minutes in the past. The value provided can be an ISO 8601 timestamp or a relative time."
    option :format, default: "short", desc: "The format to display the logs. IE: detailed or short.  With detailed, the log stream name is also shown."
    option :filter_pattern, desc: "The filter pattern to use. If not provided, all the events are matched"
    def logs
      Logs.new(options).run
    end

    desc "releases", "Show possible 'releases' or task definitions for the service."
    long_desc Help.text(:releases)
    def releases
      Releases.new(options).list
    end

    desc "rollback VERSION", "Rolls back to older task definition."
    long_desc Help.text(:rollback)
    option :wait, type: :boolean, desc: "Wait for deployment to complete", default: true
    def rollback(version)
      Rollback.new(options.merge(version: version)).deploy
    end

    desc "ps", "Show process info on ECS service."
    long_desc Help.text(:ps)
    option :status, default: "all", desc: "Status filter: all, pending, stopped, running."
    # not setting format default so we can use Ufo.config.ps.format and dont want to trigger a config load this early
    formats = CliFormat.formats + ["auto"]
    option :format, desc: "Output formats: #{formats.sort.join(', ')}"
    def ps
      Ps.new(options).run
    end

    desc "scale", "Scale the ECS service"
    long_desc Help.text(:scale)
    option :desired, type: :numeric, desc: "Desired count"
    option :min, type: :numeric, desc: "Minimum capacity"
    option :max, type: :numeric, desc: "Maximum capacity"
    def scale
      Scale.new(options).update
    end

    desc "ship", "Deploy app to ECS"
    long_desc Help.text(:ship)
    option :wait, type: :boolean, desc: "Wait for deployment to complete", default: true
    option :image, aliases: :i, desc: "Override image in task definition for quick testing"
    opts.docker
    opts.yes
    def ship
      Ship.new(options).run
    end

    desc "status", "Status of ECS service.  Essentially, status of CloudFormation stack"
    long_desc Help.text(:status)
    def status
      Status.new(options).run
    end

    desc "stop", "Stop tasks"
    long_desc Help.text(:stop)
    opts.yes
    def stop
      Stop.new(options).run
    end

    desc "completion *PARAMS", "Prints words for auto-completion."
    long_desc Help.text("completion")
    def completion(*params)
      Completer.new(CLI, *params).run
    end

    desc "completion_script", "Generates a script that can be eval to setup auto-completion.", hide: true
    long_desc Help.text("completion_script")
    def completion_script
      Completer::Script.generate
    end

    desc "version", "Prints version number of installed ufo."
    def version
      puts VERSION
    end
  end
end
