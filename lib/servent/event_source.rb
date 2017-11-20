require "servent/stream"
require "servent/event"
require "net/http"

module Servent
  class EventSource
    DEFAULT_HEADERS = { "Accept" => "text/event-stream" }

    attr_reader :ready_state, :uri

    def initialize(url, net_http_options: { read_timeout: 600 })
      @uri              = URI(url)
      @net_http_options = net_http_options
      @ready_state      = Servent::CONNECTING

      @open_blocks    = []
      @message_blocks = []
      @error_blocks   = []

      @proxy_config = ProxyConfig.new
      yield @proxy_config if block_given?
    end

    def start(http_starter = Net::HTTP)
      @http_starter ||= http_starter
      params = HTTPStartParams.new(@uri, @proxy_config, @net_http_options)

      @thread = Thread.new {
        @http_starter.start(*params.parameterize) do |http|
          get = Net::HTTP::Get.new @uri
          DEFAULT_HEADERS.each { |header, value| get[header] = value }
          yield http, get if block_given?

          perform_request http, get
        end
      }
    end

    def listen(http_starter = Net::HTTP)
      start(http_starter).join
    end

    def close
      @ready_state = Servent::CLOSED
      @thread.kill unless @thread.nil?
    end

    def on_open(&open_block)
      @open_blocks << open_block
    end

    def on_message(&message_block)
      @message_blocks << message_block
    end

    def on_error(&error_block)
      @error_blocks << error_block
    end

    private

    def perform_request(http, type)
      http.request type do |response|
        return fail_connection response if should_fail? response
        return schedule_reconnection if should_reconnect? response
        store_new_parmanent_url response

        open_connection response
      end
    end

    def open_connection(response)
      @ready_state = Servent::OPEN
      @open_blocks.each { |block| block.call response }
      response.read_body do |chunk|
        # FIXME: use the same stream object to parse
        #        different chunks.
        stream = Stream.new chunk
        events = stream.parse
        events.each do |event|
          @message_blocks.each { |block| block.call event }
        end
      end
    end

    def should_fail?(response)
      return false if Servent::REDIRECT_STATUSES.include?(response.code.to_i)
      (response["Content-Type"] != "text/event-stream") ||
        !Servent::KNOWN_STATUSES.include?(response.code.to_i)
    end

    def fail_connection(response)
      @ready_state = Servent::CLOSED
      @error_blocks.each { |block| block.call response, :wrong_mime_type }
    end

    def should_reconnect?(response)
      Servent::RECONNECTION_STATUSES.include? response.code.to_i
    end

    def schedule_reconnection
      start
    end

    def store_new_parmanent_url(response)
      return unless response.code.to_i == 301
      @original_uri = @uri
      @uri = URI(response["Location"])
    end
  end

  class ProxyConfig
    attr_accessor :host, :user, :pass
    attr_writer   :port

    def port
      @port.to_i
    end

    def empty?
      @host.nil? && @port.nil? && @user.nil? && @pass.nil?
    end

    def parameterize
      [host, port, user, pass]
    end
  end

  class HTTPStartParams
    def initialize(uri, proxy_config, options)
      @uri          = uri
      @proxy_config = proxy_config
      @options      = options
    end

    def parameterize
      params = [@uri.host, @uri.port]
      params += @proxy_config.parameterize unless @proxy_config.empty?
      params << @options
      params
    end
  end
end
