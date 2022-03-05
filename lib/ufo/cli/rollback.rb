class Ufo::CLI
  class Rollback < Base
    include Ufo::Concerns

    def deploy
      are_you_sure?
      rollback_task_definition = normalize_version(@options[:version])
      logger.info "Rolling back ECS Service to task definition: #{rollback_task_definition}"
      ship = Ship.new(@options.merge(rollback_task_definition: rollback_task_definition, rollback: true, yes: true))
      ship.run
    end

    # normalizes the task definition
    # if user passes in:
    #    1 => demo-web:1
    #    demo-web:1 => demo-web:1
    def normalize_version(version)
      if version =~ /^\d+$/
        "#{@task_definition.name}:#{version}"
      elsif version.include?(':') && !version.include?(":ufo-")
        version
      else # assume git sha
        # org/repo:ufo-2018-06-21T15-03-52-ac60240
        from_git_sha(version)
      end
    end

    def from_git_sha(sha)
      task_definition = nil
      max_items = 30
      logger.info "Looking for task definition based on the git sha.  Searching most recent #{max_items} task definitions..."
      arns = task_definition_arns(@task_definition.name, max_items)
      arns.each do |arn|
        resp = ecs.describe_task_definition(task_definition: arn)
        found = find_sha(resp.task_definition, sha)
        if found
          task_definition = arn.split('/').last
          break
        end
        print '.'
        @final_newline
      end

      logger.info '' if @final_newline
      unless task_definition
        logger.info "Unable to find a task definition with a image with: #{version}"
      end
      task_definition
    end

    def find_sha(task_definition, sha)
      container = task_definition["container_definitions"].first # assume first
      container["image"].include?(sha)
    end

  private
    def are_you_sure?
      message = "Will rollback to task definition version: #{@options[:version]}"
      if @options[:yes]
        logger.info message
      else
        sure?(message)
      end
    end
  end
end
