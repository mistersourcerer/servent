require "servent/stream"
require "servent/event"
require "net/http"

module Servent
  class EventSource
    attr_reader :ready_state

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
      params = HTTPStartParams.new(@uri, @proxy_config, @net_http_options)

      Thread.new {
        http_starter.start(*params.parameterize) do |http|
          get = Net::HTTP::Get.new @uri
          headers.each { |header, value| get[header] = value }
          yield http, get if block_given?
          perform_request http, get
        end
      }
    end

    def listen(http_starter = Net::HTTP)
      start(http_starter).join
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

    def headers
      { "Accept" => "text/event-stream" }
    end

    def perform_request(http, type)
      http.request type do |response|
        # FIXME: response CAN have more than one mime type
        return fail_connection(response) if should_fail?(response)
        handle_response response
      end
    end

    def should_fail?(response)
      (response["Content-Type"] != "text/event-stream") ||
        !Servent::KNOWN_STATUSES.include?(response.code.to_i)
    end

    def fail_connection(response)
      @ready_state = Servent::CLOSED
      @error_blocks.each { |block| block.call response, :wrong_mime_type }
    end

    def handle_response(response)
      @ready_state = Servent::OPEN
      @open_blocks.each { |block| block.call response }
      response.read_body do |chunk|
        @message_blocks.each { |block| block.call chunk }
      end
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
