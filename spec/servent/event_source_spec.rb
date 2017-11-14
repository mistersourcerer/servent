RSpec.describe Servent::EventSource do
  let(:url) { "http://example.com/event-stream" }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:adapter) {
    Faraday.new do |builder|
      builder.adapter :test, stubs
    end
  }

  subject(:event_source) { described_class.new url, adapter: adapter }

  describe ".new" do
    it "yields the `Faraday` object for further (client) connection" do
      expect { |configuration_block|
        described_class.new(url, &configuration_block)
      }.to yield_with_args(Faraday::Connection)
    end

    it "initializes #ready_state with 0 as per spec" do
      expect(event_source.ready_state).to eq 0
    end
  end

  describe "#start" do
    before do
      stubs.get("/event-stream") do |env|
        expect(env.request_headers["Accept"]).to eq "text/event-stream"
        [200, {}, ""]
      end
    end

    it "sends a GET request with right headers" do
      event_source.start.join

      stubs.verify_stubbed_calls
    end

    it "yields the (faraday) request object to a block if it is passed" do
      expect { |configuration_block|
        event_source.start(&configuration_block).join
      }.to yield_with_args(Faraday::Request)
    end

    context "reconnection"
    it "sets #ready_state with 1 as per spec" do
      expect { event_source.start.join }
        .to change { event_source.ready_state }.from(0).to(1)
    end
  end

  context "events" do
    describe "#on_open"
    describe "#on_message"
    describe "#on_error"
  end

  describe "#close"
end
