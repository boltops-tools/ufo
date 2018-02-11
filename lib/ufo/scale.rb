module Ufo
  class Scale
    include Defaults
    include AwsService

    def initialize(service, count, options={})
      @service = service
      @count = count
      @options = options
      @cluster = @options[:cluster] || default_cluster
    end

    def update
      unless service_exists?
        puts "Unable to find the #{@service} service on #{@cluster} cluster."
        puts "Are you sure you are trying to scale the right service on the right cluster?"
        exit
      end
      ecs.update_service(
        service: @service,
        cluster: @cluster,
        desired_count: @count
      )
      puts "Scale #{@service} service in #{@cluster} cluster to #{@count}" unless @options[:mute]
    end

    def service_exists?
      cluster = ecs.describe_clusters(clusters: [@cluster]).clusters.first
      return false unless cluster
      service = ecs.describe_services(services: [@service], cluster: @cluster).services.first
      !!service
    end
  end
end
