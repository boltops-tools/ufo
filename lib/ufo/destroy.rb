module Ufo
  class Destroy
    include Util
    include AwsService

    def initialize(service, options={})
      @service = service
      @options = options
      @cluster = @options[:cluster] || default_cluster
    end

    def bye
      unless are_you_sure?
        puts "Phew, that was close"
        exit
      end

      clusters = ecs.describe_clusters(clusters: [@cluster]).clusters
      if clusters.size < 1
        puts "The #{@cluster} cluster does not exist so there can be no service on that cluster to delete."
        exit
      end

      services = ecs.describe_services(cluster: @cluster, services: [@service]).services
      service = services.first
      if service.nil?
        puts "Unable to find #{@service} service to delete it."
        exit
      end
      if service.status != "ACTIVE"
        puts "The #{@service} service is not ACTIVE so no need to delete it."
        exit
      end

      # changes desired size to 0
      ecs.update_service(
        desired_count: 0,
        cluster: @cluster,
        service: @service
      )
      # Cannot find all tasks scoped to a service.  Only scoped to a cluster.
      # So will not try to stop the tasks.
      # ask to stop them
      #
      resp = ecs.delete_service(
        cluster: @cluster,
        service: @service
      )
      puts "#{@service} service has been scaled down to 0 and destroyed." unless @options[:mute]
    end

    def are_you_sure?
      return true if @options[:sure]
      puts "You are about to destroy #{@service.colorize(:green)} service on the #{@cluster.colorize(:green)} cluster."
      print "Are you sure you want to do this? (y/n) "
      answer = $stdin.gets.strip
      answer =~ /^y/
    end
  end
end
