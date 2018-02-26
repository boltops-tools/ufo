describe Ufo::Ship do
  let(:project_root) { File.expand_path("../../fixtures/hi", __FILE__) }
  let(:options) do
    {
      noop: true,
      project_root: project_root,
      mute: true,
      wait: false,
      stop_old_tasks: false,
    }
  end
  let(:service) { "hi-web-prod" }
  let(:task_definition) { service }
  let(:ship) do
    ship = Ufo::Ship.new(service, task_definition, options)
    allow(ship).to receive(:ecs).and_return(ecs_client)
    ship
  end

  context "hi-web-prod service" do
    it "should create or update service" do
      allow(ship).to receive(:process_deployment)

      ship.deploy

      expect(ship).to have_received(:process_deployment)
    end

    context "0 services found" do
      it "should create service on first cluster" do
        allow(ship).to receive(:find_ecs_service)
        allow(ship).to receive(:create_service)

        ship.deploy

        expect(ship).to have_received(:create_service)
      end
    end

    context "1 services found" do
      it "should call update service" do
        allow(ship).to receive(:find_ecs_service).and_return(ecs_service("hi-web-prod"))
        allow(ship).to receive(:update_service)

        ship.deploy

        expect(ship).to have_received(:update_service).exactly(1).times
      end
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
