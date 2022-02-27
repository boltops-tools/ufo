module Ufo::Cfn
  class Deploy < Base
    def run
      ensure_log_group_exist
      ensure_cluster_exist
      stop_old_tasks
      stack = Stack.new(@options)
      success = stack.deploy

      return unless @options[:wait]
      if success
        puts "Software shipped!"
      else
        puts "Software fail to ship."
        exit 1
      end
    end

    def ensure_cluster_exist
      return unless Ufo.config.ecs.create_cluster

      cluster = ecs_clusters.first
      exist = cluster && cluster.status == "ACTIVE"
      return if exist

      ecs.create_cluster(cluster_name: @cluster)
      logger.info "#{@cluster} cluster created."
    end

    def ecs_clusters
      ecs.describe_clusters(clusters: [@cluster]).clusters
    end

    # Start a thread that will poll for ecs deployments and kill of tasks in old deployments.
    # This must be done in a thread because the stack update process is blocking.
    def stop_old_tasks
      return unless @options[:stop_old_tasks]
      return unless @options[:wait] # only works when deployment is blocking

      Thread.new do
        stop = Ufo::Stop.new(@options.merge(mute: true))
        while true
          stop.log "checking for old tasks and waiting for 10 seconds"
          stop.run
          sleep 10
        end
      end
    end

    def ensure_log_group_exist
      Ufo::LogGroup.new(@options).create
    end
  end
end
