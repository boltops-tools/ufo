require 'spec_helper'

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
  let(:task_definition) { service }
  let(:ship) { Ufo::Ship.new(service, task_definition, options) }

  context "single service id" do
    let(:service) { "hi-web-prod" }
    it "should create or update single service" do
      allow(ship).to receive(:process_single_service)
      ship.deploy
      expect(ship).to have_received(:process_single_service)
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
      it "should call update service 3 times" do
        allow(ship).to receive(:find_ecs_service).and_return(ecs_service("hi-web-prod"))
        allow(ship).to receive(:update_service)
        ship.deploy
        expect(ship).to have_received(:update_service).exactly(1).times
      end
    end
  end

  context "multiple service pattern" do
    let(:service) { "hi-.*-prod" }
    it "should update multiple service that are found" do
      allow(ship).to receive(:process_multiple_services)
      ship.deploy
      expect(ship).to have_received(:process_multiple_services)
    end

    context "0 services found" do
      it "should not call update_service" do
        allow(ship).to receive(:find_all_ecs_services)
        allow(ship).to receive(:update_service)
        ship.deploy
        expect(ship).to_not have_received(:update_service)
      end
    end

    context "3 services found" do
      it "should call update service 3 times" do
        allow(ship).to receive(:find_all_ecs_services).
                          and_yield(ecs_service("hi-web-prod")).
                          and_yield(ecs_service("hi-worker-prod")).
                          and_yield(ecs_service("hi-clock-prod"))
        allow(ship).to receive(:update_service)
        ship.deploy
        expect(ship).to have_received(:update_service).exactly(3).times
      end
    end
  end

  def ecs_service(name)
    OpenStruct.new(service_name: name)
  end
end
