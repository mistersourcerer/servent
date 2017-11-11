RSpec.describe Servent::Event do
  context "data:" do
    it "recognizes a simple `data: omg` stream" do
      event = described_class.new "data: omg"

      expect(event).to be_event("message", "omg")
    end

    it 'removes just one space from message `data:\s\somg`' do
      event = described_class.new "data:\s\somg"

      expect(event).to be_event("message", " omg")
    end
  end

  context "custom event types" do
    it 'recognizes a type with its content `event: omg\ndata: lol`' do
      event = described_class.new "event: omg\ndata: lol"

      expect(event).to be_event("omg", "lol")
    end
  end

  context "extra fields" do
    context "`id`" do
      it 'recognizes the `id` on an Event `event: omg\ndata: lol\nid:123`' do
        event = described_class.new "event: omg\ndata: lol\nid: 123"

        expect(event).to be_event("omg", "lol")
        expect(event.id).to eq("123")
      end
    end

    context "`retry`" do
      it 'recognizes `retry` on an Event `event: omg\ndata: lol\nretry:10`' do
        event = described_class.new "event: omg\ndata: lol\nretry: 10"

        expect(event).to be_event("omg", "lol")
        expect(event.retry).to eq 10
      end

      it "returns zero if can convert retry to int" do
        event = described_class.new "data: lol\nretry: amagahd"

        expect(event.retry).to eq 0
      end
    end

    it "recognizes many fields `event: omg\ndata: lol\nid:123\nretry:10`" do
      event = described_class.new "event: omg\ndata: lol\nid:123\nretry:10"

      expect(event).to be_event("omg", "lol")
      expect(event.id).to eq("123")
      expect(event.retry).to eq 10
    end
  end

  context "specification examples" do
    it "recongnizes the generic multilined event stream" do
      stream = "data: YHOO\ndata: +2\ndata: 10"
      event  = described_class.new stream

      expect(event).to be_event("message", "YHOO\n+2\n10")
    end
  end
end
