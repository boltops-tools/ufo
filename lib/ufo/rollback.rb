module Ufo
  class Rollback < Base
    def deploy
      task_definition = normalize_version(@options[:version])
      puts "Rolling back ECS service to task definition #{task_definition}"
      ship = Ship.new(@service, @options.merge(task_definition: task_definition))
      ship.deploy
    end

    # normalizes the task definition
    # if user passes in:
    #    1 => demo-web:1
    #    demo-web:1 => demo-web:1
    def normalize_version(version)
      if version =~ /^\d+$/
        "#{@service}:#{version}"
      elsif version.include?(':') && !version.include?(":ufo-")
        version
      else # assume git sha
        # tongueroo/hi:ufo-2018-06-21T15-03-52-ac60240
        from_git_sha(version)
      end
    end

    def from_git_sha(sha)
      task_definition = nil
      max_items = 30
      puts "Looking for task definition based on the git sha.  Searching most recent #{max_items} task definitions..."
      arns = task_definition_arns(@service, max_items)
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

      puts '' if @final_newline
      unless task_definition
        puts "Unable to find a task definition with a image with: #{version}"
      end
      task_definition
    end

    def find_sha(task_definition, sha)
      container = task_definition["container_definitions"].first # assume first
      container["image"].include?(sha)
    end
  end
end
