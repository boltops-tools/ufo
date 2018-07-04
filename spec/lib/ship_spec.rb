describe Ufo::Ship do
  let(:options) do
    {
      noop: true,
      mute: true,
      wait: false,
      task_definition: service,
      stop_old_tasks: false,
    }
  end
  let(:service) { "demo-web-prod" }
  let(:ship) do
    ship = Ufo::Ship.new(service, options)
    allow(ship).to receive(:ecs).and_return(ecs_client)
    ship
  end

  context "demo-web-prod service" do
    it "should create or update service" do
      allow(ship).to receive(:deploy_stack)

      ship.deploy

      expect(ship).to have_received(:deploy_stack)
    end
  end

  # mocks
  def ecs_client
    ecs = double("ecs")
    allow(ecs).to receive(:describe_clusters).and_return(ecs_describe_clusters)
    ecs
  end

  # ensure_cluster_exist calls this and this makes sure that the cluster 'exists'
  def ecs_describe_clusters
    describe_clusters = double("ecs-describe-clusters")
    cluster1 = OpenStruct.new(status: "ACTIVE")
    allow(describe_clusters).to receive(:clusters).and_return([cluster1])
    describe_clusters
  end

  def ecs_service(name)
    OpenStruct.new(service_name: name)
  end
end
