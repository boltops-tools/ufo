describe Ufo::Utils::Squeezer do
  subject { Ufo::Utils::Squeezer.new(data) }

  context("Array with nil") do
    let(:data) { [nil] }
    # Prevents infinite loop
    it "remove nil" do
      squeezed = subject.squeeze
      expect(squeezed).to eq []
    end
  end

  context("Hash with nil value") do
    let(:data) { {a: 1, b: nil } }
    # Prevents infinite loop
    it "remove nil" do
      squeezed = subject.squeeze
      expect(squeezed).to eq(a: 1)
    end
  end
end
