class Ufo::Ships
  def initialize(services, task_definitions, options={})
    @services = services
    @task_definitions = task_definitions

    @options = options
    @project_root = options[:project_root] || '.'
    @elb_prompt = @options[:elb_prompt].nil? ? true : @options[:elb_prompt]
    @cluster = @options[:cluster] || default_cluster
    @wait_for_deployment = @options[:wait].nil? ? true : @options[:wait]
    @stop_old_tasks = @options[:stop_old_tasks].nil? ? false : @options[:stop_old_tasks]
  end

  def deploy
    @services.each do |service|

      builder = build_docker(options)
      task_definition = options[:task] || service # convention
      register_task(task_definition, options)
      return if ENV['TEST'] # allows quick testing of the ship CLI portion only

      ship = Ship.new(service, task_definition, options)
      ship.deploy
      if options[:docker]
        DockerCleaner.new(builder.image_name, options).cleanup
        EcrCleaner.new(builder.image_name, options).cleanup
      end
      puts "Docker image shipped: #{builder.full_image_name.green}"

    end
  end
end
