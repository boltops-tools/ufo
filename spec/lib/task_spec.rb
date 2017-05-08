require 'spec_helper'

describe Ufo::Ship do
  let(:project_root) { File.expand_path("../../fixtures/hi", __FILE__) }
  let(:options) do
    {
      project_root: project_root,
      mute: true
    }
  end
  let(:task_definition) { "hi-migrate-prod" }
  let(:task) do
    task = Ufo::Task.new(task_definition, options)
    allow(task).to receive(:ecs).and_return(ecs_client)
    task
  end

  context "hi-migrate-prod" do
    it "should migrate the database" do
      task.run

      expect(task.ecs).to have_received(:run_task)
    end
  end

  # mocks
  def ecs_client
    ecs = double("ecs")
    fake_response = double('fake-response').as_null_object
    allow(ecs).to receive(:run_task).and_return(fake_response)
    ecs
  end
end
