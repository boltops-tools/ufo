describe Ufo::Task do
  before(:each) do
    create_ufo_project
  end
  let(:options) do
    {
      mute: true
    }
  end
  let(:task_definition) { "hi-migrate-prod" }

  context "hi-migrate-prod" do
    it "should migrate the database" do
      task.run

      expect(task.ecs).to have_received(:run_task)
    end

    it "should wait for the command to finish" do
      expect do
        task(wait: true, timeout: 600).run
        expect(task.ecs).to have_received(:run_task)
      end.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(5)
      end
    end
  end

  # mocks
  def ecs_client
    ecs = double("ecs")
    ecs_container = double("ecs_container")
    fake_response = double('fake-response').as_null_object
    allow(ecs).to receive(:run_task).and_return(fake_response)
    allow(ecs).to receive(:wait_until).and_return(fake_response)
    allow(ecs).to receive(:describe_tasks).and_return(OpenStruct.new({
      tasks: [OpenStruct.new(containers: [ecs_container])]
    }))
    allow(ecs).to receive(:list_task_definitions).and_return(fake_response)
    allow(ecs).to receive(:describe_task_definition).and_return(fake_response)
    allow(ecs_container).to receive(:exit_code).and_return(5)
    ecs
  end

  def task option_overwrites = {}
    @task ||=
      begin
        task = Ufo::Task.new(task_definition, options.merge(option_overwrites))
        allow(task).to receive(:ensure_log_group_exist) # stub not so not called
        allow(task).to receive(:ecs).and_return(ecs_client)
        task
      end
  end
end
