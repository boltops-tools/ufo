describe Ufo::IamRole::DSL do
  let(:dsl) { described_class.new(path) }
  let(:path) { "spec/fixtures/iam_roles/task_role.rb" }

  context "evaluate" do
    it "registers policies from role DSL" do
      dsl.evaluate
      expect(Ufo::IamRole::Registry.policies).not_to be_empty
      expect(Ufo::IamRole::Registry.managed_policies).not_to be_empty
    end
  end
end
