RSpec.describe Servent::Stream do
  describe "#parse" do
    context ":comment" do
      it "ignores streams starting with `:`" do
        stream = described_class.new ":omg a comment!"

        events = stream.parse
        expect(events.count).to eq 0
      end
    end

    context "data:" do
      it "recognizes a simple `data: omg` stream" do
        stream = described_class.new "data: omg"
        events = stream.parse

        expect(events.count).to eq 1
      end
    end

    context "multiline stream" do
      it 'generates only one event for the pattern `event: omg\ndata: lol`' do
        stream = described_class.new "event: omg\ndata: lol"
        events = stream.parse

        expect(events.count).to eq 1
      end
    end
  end
end
