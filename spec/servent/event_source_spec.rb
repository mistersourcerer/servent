RSpec.describe Servent::EventSource do
  let(:url) { "http://example.com/event-stream" }
  let(:body) {
    <<~BODY
      event: omg
      id: 42
      data: this is a message!
    BODY
  }
  let(:headers) { { "Accept" => "text/event-stream" } }
  let(:response_headers) { { "Content-Type" => "text/event-stream" } }
  let(:status) { 200 }
  let(:stub) {
    stub_request(:get, url)
      .with(headers: headers)
      .to_return(body: body, status: status, headers: response_headers)
  }

  subject(:event_source) { described_class.new url }

  before do
    stub
  end

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
          .with("example.com",
                8080,
                "http://proxy.omg",
                443,
                "user",
                "pass",
                Hash)

        event_source.start(http_starter).join
      end

      it "passes the http extra options when they are available" do
        options = { read_timeout: 30 }
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

  describe "#listen" do
    it "starts and joins the internal thread in one go" do
      fake_thread = double(Thread)
      allow(event_source).to receive(:start).and_return fake_thread
      expect(fake_thread).to receive(:join)

      event_source.listen
    end

    it "repasses 'http_starter' if one is passed to listen" do
      http_starter = double(Net::HTTP)
      fake_thread = double(Thread)
      allow(event_source).to receive(:start)
        .with(http_starter)
        .and_return fake_thread
      expect(fake_thread).to receive(:join)

      event_source.listen http_starter
    end
  end

  context "http connection" do
    context "when response mime type is not text/event-stream" do
      let(:response_headers) { { "Content-Type" => "text/omg-lol" } }

      it "does not open the connection" do
        expect { |open_block| event_source.on_open(&open_block) }
          .to_not yield_control
        event_source.start.join

        expect(event_source.ready_state).to eq Servent::CLOSED
      end

      it "yields the `on_error` block" do
        expect { |error_block|
          event_source.on_error(&error_block)
          event_source.start.join
        }.to yield_with_args(Net::HTTPResponse, :wrong_mime_type)
      end
    end

    context "unexpected status code" do
      let(:status) { 560 }

      it "triggers `on_error` block if response has unexpected status" do
        expect { |error_block|
          event_source.on_error(&error_block)
          event_source.start.join
        }.to yield_control
      end
    end

    context "reconnection" do
      let(:status) { 500 }

      before do
        stub.to_return body: body, status: 200, headers: response_headers
      end

      it "schedules a reconnection task" do
        allow(Thread).to receive(:new).and_yield
        expect(Thread).to receive(:new).twice

        # This test is a little bit difficult of visualize =(
        # The first time the eventsource hits (Thread.new),
        #   it will receive a reconnect status code
        #   so the second stub takes place
        #   and a second call to Thread.new takes place
        event_source.start
      end
    end
  end

  context "events" do
    RSpec.shared_examples "an event" do |register_method|
      let(:register_method) { register_method }

      it "execute blocks passed using the register method" do
        first_block  = -> {}
        second_block = -> {}
        event_source.public_send(register_method, &first_block)
        event_source.public_send(register_method, &second_block)
        expect(first_block).to receive(:call)
        expect(second_block).to receive(:call)

        event_source.start.join
      end
    end

    it_behaves_like "an event", :on_open
    it_behaves_like "an event", :on_message

    describe "#on_error" do
      let(:response_headers) { { "Content-Type" => "text/omg-lol" } }

      it_behaves_like "an event", :on_error
    end
  end

  describe "#close" do
    let(:blocking_response) { BlockingResponse.new }

    before do
      stub.to_return { blocking_response.block }
    end

    it "kills the Thread waiting for response" do
      thread = event_source.start
      expect(thread).to receive(:kill)

      event_source.close
      thread.join

      expect(thread.alive?).to eq false
      expect(event_source.ready_state).to eq Servent::CLOSED
    end
  end
end
