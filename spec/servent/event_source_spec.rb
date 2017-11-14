RSpec.describe Servent::EventSource do
  let(:url) { "http://example.com/event-stream" }
  let!(:stub) {
    stub_request(:get, url)
      .with(body: "", headers: { "Accept" => "text/event-stream" })
  }

  subject(:event_source) { described_class.new url }

  describe ".new" do
    it "initializes #ready_state with 0 as per spec" do
      expect(event_source.ready_state).to eq 0
    end
  end

  describe "#start" do
    it "sends a GET request with right header (text/event-stream)" do
      event_source.start.join
      expect(stub).to have_been_requested
    end

    it "yields the HTTP and the Get objects to a block" do
      expect { |configuration_block|
        event_source.start(&configuration_block).join
      }.to yield_with_args(Net::HTTP, Net::HTTP::Get)
    end

    it "sets #ready_state with 1 as per spec" do
      expect { event_source.start.join }
        .to change { event_source.ready_state }.from(0).to(1)
    end
  end

  context "reconnection"

  context "events" do
    describe "#on_open" do
      it "stores the parameter block to be called later when opening con" do
        expect { |on_open_block|
          event_source.on_open(&on_open_block)
          event_source.start.join
        }.to yield_control
      end
    end

    describe "#on_message"
    describe "#on_error"
  end

  describe "#close"
end
