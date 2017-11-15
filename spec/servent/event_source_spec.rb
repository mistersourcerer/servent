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

    it "yields a ProxyConfig object if a block is given" do
      expect { |proxy_config| described_class.new(url, &proxy_config) }
        .to yield_with_args(Servent::ProxyConfig)
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

    context "configurations" do
      it "uses proxy configuration when some was made on initializer" do
        event_source = described_class.new "http://example.com:8080" do |proxy|
          proxy.host = "http://proxy.omg"
          proxy.port = "443"
          proxy.user = "user"
          proxy.pass = "pass"
        end

        http_starter = double(Net::HTTP)
        expect(http_starter).to receive(:start)
          .with(
            "example.com",
            8080,
            "http://proxy.omg",
            443,
            "user",
            "pass",
            Hash)

        event_source.start(http_starter).join
      end

      it "passes the http extra options when they are available" do
        options = {read_timeout: 30}
        event_source = described_class.new(
          "http://example.com",
          net_http_options: options
        )
        http_starter = double(Net::HTTP)
        expect(http_starter).to receive(:start)
          .with("example.com", 80, options)

        event_source.start(http_starter).join
      end
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
