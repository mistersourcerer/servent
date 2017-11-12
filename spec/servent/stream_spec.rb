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

    context "unknown fields" do
      it "don't explodes when trying create a invalid (unkown field) event" do
        expect {
          described_class.new("neh: boom!").parse
        }.to_not raise_error
      end
    end

    context "multiline stream" do
      it 'generates only one event for the pattern `event: omg\ndata: lol`' do
        stream = described_class.new "event: omg\ndata: lol"
        events = stream.parse

        expect(events.count).to eq 1
      end

      context "multiple events on the same stream" do
        it "accumulates all (3) events in the stream" do
          events = <<~STREAM
            : test stream

            data: first event
            id: 1

            data:second event
            id

            data:  third event
          STREAM
          events = described_class.new(events).parse

          expect(events.count).to eq 3
        end
      end
    end

    describe "`Last-Event-ID`" do
      it 'holds the id received on the `event: omg\ndata: lol\nid:123`' do
        stream = described_class.new "event: omg\ndata: lol\nid:123"
        stream.parse

        expect(stream.last_event_id).to eq "123"
      end

      it "cleans id if consecutive message has a blank one" do
        events = <<~STREAM
          : test stream

          data: first event
          id: 1

          data:second event
          id
        STREAM
        stream = described_class.new(events)
        stream.parse

        expect(stream.last_event_id).to eq nil
      end
    end

    describe "#reconnection_time" do
      it "stores the time defined by the last event (with the field)" do
        events = <<~STREAM
          data: first event
          retry: 1

          data:second event
          retry: 2
        STREAM

        stream = described_class.new(events)
        stream.parse

        expect(stream.reconnection_time).to eq 2
      end
    end
  end
end
