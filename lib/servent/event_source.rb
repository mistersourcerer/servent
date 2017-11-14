require "servent/stream"
require "servent/event"

module Servent
  class EventSource
    def initialize(url, adapter: nil, &configurator)
      @uri     = URI(url)
      adapter  = create_faraday(&configurator) if adapter.nil?
      @adapter = adapter
    end

    def start
      Thread.new do
        @adapter.get(@uri.path) do |req|
          req.headers["Accept"] = "text/event-stream"
          yield(req) if block_given?
      end
    end

    private

    def create_faraday
      Faraday.new(url: @uri) do |faraday|
        yield(faraday) if block_given?
      end
    end
  end
end
