require "servent/stream"
require "servent/event"
require "net/http"

module Servent
  class EventSource
    attr_reader :ready_state

    def initialize(url,
                   proxy_host: nil,
                   proxy_port: nil,
                   proxy_user: nil,
                   proxy_pass: nil,
                   net_http_options: { read_timeout: 600 }
                  )
      @uri = URI(url)
      @ready_state = Servent::CONNECTING
    end

    def start(requester = nil)
      Thread.new do
        Net::HTTP.start(@uri.host, @uri.port, read_timeout: 600) do |http|
          requester ||= http
          get = Net::HTTP::Get.new @uri
          get["Accept"] = "text/event-stream"
          yield(http, get) if block_given?

          requester.request(get) do |response|
            @ready_state = Servent::OPEN
            @open_block.call(response) unless @open_block.nil?

            # response.read_body do |chunk|
            # end
          end
        end
      end
    end

    def on_open(&open_block)
      @open_block = open_block
    end

    private

    def create_faraday
      Faraday.new(url: @uri) do |faraday|
        yield(faraday) if block_given?
      end
    end
  end
end
