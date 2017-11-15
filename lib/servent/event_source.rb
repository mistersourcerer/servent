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

    def on_open(&open_block)
      @open_blocks << open_block
    end

    private

    def headers
      { "Accept" => "text/event-stream" }
    end

    def perform_request(http, type)
      http.request type do |response|
        @ready_state = Servent::OPEN
        @open_blocks.each { |block| block.call(response) }

        # response.read_body do |chunk|
        # end
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
