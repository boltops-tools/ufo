class Ufo::Stack::Builder::Resources::TaskDefinition
  class Reconstructor
    include Ufo::AwsService

    def initialize(task_definition, rollback=false)
      @task_definition, @rollback = task_definition, rollback
    end

    def reconstruct
      camelize(data)
    end

    def data
      if @rollback
        resp = ecs.describe_task_definition(task_definition: @task_definition)
        resp.task_definition.to_h
      else
        path = "#{Ufo.root}/.ufo/output/#{@task_definition}.json"
        JSON.load(IO.read(path))
      end
    end

    # non-destructive
    def camelize(value, parent_keys=[])
      case value
      when Array
        value.map { |v| camelize(v, parent_keys) }
      when Hash
        initializer = value.map do |k, v|
          new_key = camelize_key(k, parent_keys)
          [new_key, camelize(v, parent_keys+[new_key])]
        end
        Hash[initializer]
      else
        value # do not camelize values
      end
    end

    def camelize_key(k, parent_keys=[])
      k = k.to_s
      special = %w[Options] & parent_keys.map(&:to_s)
      if special.empty?
        k.camelize
      else
        k # pass through untouch
      end
    end
  end
end
