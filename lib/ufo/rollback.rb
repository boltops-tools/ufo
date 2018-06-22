module Ufo
  class Rollback < Base
    def deploy
      task_definition = normalize_version(@options[:version])
      puts "Rolling back ECS service to task definition #{task_definition}"
      puts "@service #{@service.inspect}"
      puts "@options[:version] #{@options[:version].inspect}"
      puts "task_definition #{task_definition.inspect}"
      ship = Ship.new(@service, @options.merge(task_definition: task_definition))
      ship.deploy
    end

    # normalizes the task definition
    # if user passes in:
    #    1 => hi-web:1
    #    hi-web:1 => hi-web:1
    def normalize_version(version)
      if version =~ /^\d+$/
        "#{@service}:#{version}"
      else
        version
      end
    end
  end
end
