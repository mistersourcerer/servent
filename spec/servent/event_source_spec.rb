RSpec.describe Servent::EventSource do
  let(:url) { "http://example.com/event-stream" }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:adapter) {
    Faraday.new do |builder|
      builder.adapter :test, stubs
    end
  }

  subject(:event_source) { described_class.new url, adapter: adapter }

  describe "#start" do
    it "sends a GET request with right headers" do
      stubs.get("/event-stream") do |env|
        expect(env.request_headers["Accept"]).to eq "text/event-stream"
        [200, {}, ""]
      end
      event_source.start

      stubs.verify_stubbed_calls
    end

    context "reconnection"
  end

  context "events" do
    describe "#on_open"
    describe "#on_message"
    describe "#on_error"
  end

  describe "#close"
end
